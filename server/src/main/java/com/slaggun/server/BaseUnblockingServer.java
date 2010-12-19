/*
 * Copyright 2009 SlagGunTeam
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software distributed under the
 * License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
 * either express or implied. See the License for the specific language governing permissions
 * and limitations under the License.
 */

package com.slaggun.server;

import static com.slaggun.util.Assert.notNull;
import org.apache.log4j.Logger;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.nio.ByteBuffer;
import java.nio.channels.*;
import java.util.Iterator;
import java.util.Set;
import java.util.HashSet;
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

/**
 * Multiplexed multithreaded non-blocking game server.
 *
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
public abstract class BaseUnblockingServer<S extends BaseUnblockingServer.Session> {

    protected abstract class Session{
		private SelectionKey clientKey;
		private ByteBuffer inputBuffer = ByteBuffer.allocate(serverProperties.getReadBufferSize());
		private ConcurrentLinkedQueue<ByteBuffer> outputQueue = new ConcurrentLinkedQueue<ByteBuffer>();
		private boolean closed = false;

        public ByteBuffer getInputBuffer(){
			return inputBuffer;
		}

		public void closeSession(){
			try {
				SocketChannel socketChannel = (SocketChannel) clientKey.channel();
				clientKey.cancel();
				socketChannel.close();
				close(clientKey);								
			} catch (IOException e) {
				throw new RuntimeException(e);
			}
		}

		/**
		 * Post buffer in queuue to send.
		 * It means that if buffer is changed after the post operation, new data may be send to the client
		 * @param lockedBuffer - buffer to be posted on write queue
		 */
		public void postBuffer(ByteBuffer lockedBuffer){
			outputQueue.offer(lockedBuffer);
			flush();
		}



		/**
		 * Post byte array in queuue to send.
		 * It means that if byte lockedArray is changed after the post operation, new data may be send to the client
		 * @param lockedArray - array to be postend in write queue
		 */
		public void postArray(byte[] lockedArray){
			outputQueue.offer(ByteBuffer.wrap(lockedArray));
			flush();
		}

		/**
		 * Post byte array in queuue to send.
		 * It means that if byte lockedArray is changed after the post operation, new data may be send to the client
		 * @param lockedArray - array to be postend in write queue
		 * @param offset - first byte to be written
		 * @param lenght - length of byte set after the ofsset to be written
		 */
		public void postArray(byte[] lockedArray, int offset, int lenght){
			outputQueue.offer(ByteBuffer.wrap(lockedArray, offset, lenght));
			flush();
		}

		public void flush() {
			if(clientKey.isValid()){
				clientKey.interestOps(SelectionKey.OP_READ | SelectionKey.OP_WRITE);
				selector.wakeup();
			}
		}

		private void setClientKey(SelectionKey clientKey) {
			this.clientKey = clientKey;
		}

		private void updateBuffer(){
			SocketChannel socketChannel = (SocketChannel) clientKey.channel();

			int numRead;
			try {
				numRead = socketChannel.read(inputBuffer);
			} catch (IOException e) {
				numRead = -1;
			}

			if (numRead == -1) {
				closeSession();
			}
		}

		private void write() {

			SocketChannel socketChannel = (SocketChannel) clientKey.channel();

			ByteBuffer outputBuffer ;
			while((outputBuffer = outputQueue.poll()) != null){
				try {
					socketChannel.write(outputBuffer);
				} catch (IOException e) {
					log.error("Can't write output buffer");
				}
			}

			clientKey.interestOps(SelectionKey.OP_READ);
		}
	}

    private static Logger log = Logger.getLogger(BaseUnblockingServer.class);

    private ServerProperties serverProperties;
    private Selector selector;
    private boolean running;

    // blocking queue to hold submitted tasks of incoming events packets processing
    private ArrayBlockingQueue<Runnable> packetHandlers;

    // executes submitted tasks of incoming events packets processing
    private ThreadPoolExecutor workersPool;

    public BaseUnblockingServer(ServerProperties serverProperties) {
        notNull(serverProperties, "serverProperties must not be null");
        this.serverProperties = serverProperties;
    }

	/**
     * Start game server, so it will be ready to accept connections
     *
     * @throws IOException problems with server initializtion
     */
    public void start() throws IOException {
        initialize();
        acceptConnections();
    }

	public void stop() {
		try {
			Set<SelectionKey> selectionKeySet = selector.keys();
			for (SelectionKey selectionKey : new HashSet<SelectionKey>(selectionKeySet)) {
				selectionKey.channel().close();
			}
			selector.close();
		} catch (IOException e) {
			throw new RuntimeException(e);
		}
	}

    /**
     * Prepare game server:
     * - listen socket
     * - prepare workers thread pool
     * - create game world from scratch
     *
     * @return game server
     * @throws IOException error during attempt to listen socket
     */
    public BaseUnblockingServer initialize() throws IOException {
        log.info("Initializing game server");
        ServerSocketChannel serverSocketChannel = ServerSocketChannel.open();
        selector = Selector.open();
        serverSocketChannel.configureBlocking(false);

        // bind to localhost:port
        int port = serverProperties.getGameServerPort();
        log.info("Listening port: " + port);
        serverSocketChannel.socket().bind(new InetSocketAddress(port));

        // register the channel with the selector to handle new socket connections
        serverSocketChannel.register(selector, SelectionKey.OP_ACCEPT);

        // blocking bounded queue to hold submitted tasks setOf incoming events packets processing
        int packetHandlersQueueSize = serverProperties.getPacketHandlersQueueSize();
        packetHandlers = new ArrayBlockingQueue<Runnable>(packetHandlersQueueSize);

        // thread pool for events packets processing
        initializeWorkersPool();
	    
        return this;
    }

	protected abstract S createSession();
	protected abstract void onAccept(S session);
	protected abstract void onDataReceived(S session);
	protected abstract void onClose(S session);

    /**
     * Accept connections. Main loop of the server.
     */
    private void acceptConnections() {
        running = true;
        log.debug("Accept connections");

        workersPool.prestartAllCoreThreads();
        log.debug("Workers pool is ready to process event packets");

        while (running) {
	        try {
                // blocking select, may wait for connection for a long time
                int interestingKeysNumber = selector.select();

                if (interestingKeysNumber == 0) {
                    // nothing to do if there are no new acceptable channels
                    continue;
                }

                Set<SelectionKey> readyKeys = selector.selectedKeys();
                Iterator<SelectionKey> keysIterator = readyKeys.iterator();
                while (keysIterator.hasNext()) {
                    SelectionKey key = keysIterator.next();
                    keysIterator.remove();
	                try{

						if (!key.isValid()) {
							continue;
						}

		                //TODO make read multitasking

						if (key.isAcceptable()) {
							accept(key);
						}
						if (key.isReadable()) {
							read(key);
						}
						if (key.isWritable()) {
							write(key);
						}

	                }catch(CancelledKeyException e){
		                log.debug("Connection have been closed", e);
		                close(key);
		            }catch (Exception e){
		                log.error("Error in the loop", e);
	                }
                }
                // don't bother with exceptions in the loop
            } catch (Exception e) {
                log.error("Error in the loop", e);
            }
        }

    }

	private void close(SelectionKey key) {
		S session = (S) key.attachment();
		if(!session.closed){
			session.closed = true;
			onClose(session);
		}
	}

	/**
     * Initialize workers thread pool with server properties
     */
    private void initializeWorkersPool() {
//        int availableProcessors = serverProperties.getAvailableProcessors();
//        int ioThreadsNumber = 1;
        // TODO: for testing
        int corePoolSize = 2;
        int maxPoolSize = 2;
//        int maxPoolSize = availableProcessors == 1 ? 1 : availableProcessors - ioThreadsNumber;
        long keepAliveTime = 10;
        TimeUnit unit = TimeUnit.SECONDS;

        workersPool = new ThreadPoolExecutor(corePoolSize, maxPoolSize, keepAliveTime, unit, packetHandlers);

        log.info("Workers thread pool is initialized with the following:");
        log.info("Core pool size: " + corePoolSize);
        log.info("Max pool size: " + maxPoolSize);
        log.info("Keep alive time: " + "10 " + unit);
    }
	
    /**
     * Accept new connection
     *
     * @param key represents channel of new connection
     * @throws IOException -
     */
    private void accept(SelectionKey key) throws IOException {
        log.debug("Accepting new connection ...");
        ServerSocketChannel serverSocketChannel = (ServerSocketChannel) key.channel();

        // accept new connection
        SocketChannel socketChannel = serverSocketChannel.accept();
        // turn Nagle's algorithm off, use non blocking socket
        socketChannel.socket().setTcpNoDelay(true);
        socketChannel.configureBlocking(false);

	    S session = createSession();

	    // we'd like to be notified when there's data waiting to be read
	    SelectionKey clientKey = socketChannel.register(this.selector, SelectionKey.OP_READ | SelectionKey.OP_WRITE, session);

	    session.setClientKey(clientKey);

	    onAccept(session);
    }

    /**
     * Reads from channel, hands the data off to the worker threads
     * If we've managed to read at least one complete event, set interest in OP_WRITE
     *
     * @param key represents channel of the connection
     * @throws IOException -
     */
    private void read(SelectionKey key) throws IOException {
        log.debug("reading from channel ...");
        S session = (S) key.attachment();

        session.updateBuffer();

	    ByteBuffer buffer = session.getInputBuffer();

	    buffer.flip();
	    try{
		    onDataReceived(session);
	    }catch(CancelledKeyException e){
		    log.warn("onDataReceived: CancelledKeyException have been retrieved while read(see debug log for details).");
		    log.error("onDataReceived CancelledKeyException exception", e);
			throw e;
	    }catch (Exception e){
		    log.error("Error while reading",e);
	    }finally {
		    buffer.compact();
	    }

        log.debug("reading done");
    }

    /**
     * Writes to channel.
     * Look at the head packet of outgoing queue.
     * If we intersted in it, send to client.
     * <p/>
     *
     * @param key represents channel of the connection
     * @throws IOException -
     */
    private void write(SelectionKey key) throws IOException {        
        Session session = (Session) key.attachment();

        session.write();
        key.interestOps(SelectionKey.OP_READ);
    }

    public boolean isRunning() {
        return running;
    }

    public void setRunning(boolean running) {
        this.running = running;
    }
}
