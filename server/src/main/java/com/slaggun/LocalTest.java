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

package com.slaggun;

import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.BlockingQueue;

/**
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
public class LocalTest {
    public static void main(String[] args) throws InterruptedException {
//        ArrayBlockingQueue<String> queue = new ArrayBlockingQueue<String>(2);
//        queue.put("1");
//        queue.put("2");
//
//        System.out.println(queue.take());
//        System.out.println(queue.take());
//        System.out.println(queue.take());

        BlockingQueue<Runnable> tasks = new ArrayBlockingQueue<Runnable>(5);

        ThreadPoolExecutor poolExecutor =
                new ThreadPoolExecutor(2, 2, 10, TimeUnit.SECONDS, tasks);

        poolExecutor.prestartAllCoreThreads();
        tasks.put(new Task());
        System.out.println("after putting new task");


        Thread.sleep(2000);
        tasks.put(new Task());
    }


}


class Task implements Runnable {

    public void run() {
        try {
            Thread.sleep(5000);
            System.out.println("done");
        } catch (InterruptedException e) {
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
        }
    }
}