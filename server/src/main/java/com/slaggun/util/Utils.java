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

package com.slaggun.util;

import org.apache.log4j.Logger;

import java.io.*;
import java.nio.charset.Charset;
import java.util.Set;
import java.util.HashSet;
import java.util.Arrays;

/**
 * @author Oleksiy Dyagilev (aka.fe2s@gmail.com)
 */
public class Utils {
    public static Logger LOG = Logger.getLogger(Utils.class);

    private Utils() {
    }

    public static int toInt(byte[] bytes) {
        return bytes[0] << 24 |
                (bytes[1] & 0xff) << 16 |
                (bytes[2] & 0xff) << 8 |
                (bytes[3] & 0xff);
    }

    public static byte[] toBytes(int i) {
        return new byte[]{
                (byte) (i >> 24),
                (byte) (i >> 16),
                (byte) (i >> 8),
                (byte) i};
    }

	public static String readFromStream(InputStream stream) {		
		Reader reader = new InputStreamReader(stream);
		reader = new BufferedReader(reader);

		StringBuilder buffer = new StringBuilder();
		char[] charsBuffer = new char[4096];
		int size;
		try {
			while ((size = reader.read(charsBuffer)) != -1) {
				buffer.append(charsBuffer, 0, size);
			}
		} catch (IOException e) {
			throw new RuntimeException("Error during stream reading", e);
		} finally {
            release(reader);
        }

		return buffer.toString();
	}

    public static void release(Reader reader){
        try {
            reader.close();
        } catch (IOException e) {
            throw new RuntimeException("Error during reader closing", e);
        }
    }

	public static <T> Set<T> setOf(T ... elements){
        Set<T> set = new HashSet<T>(elements.length);
        set.addAll(Arrays.asList(elements));
        return set;
    }

    public static String fromUTF8(byte[] bytes){
        try {
            return new String(bytes, "UTF-8");
        } catch (UnsupportedEncodingException e) {
            LOG.warn("Can't decode string with UTF-8, using default: '" + Charset.defaultCharset().name() + "' instead", e);
            return new String(bytes);
        }
    }

    public static byte[] toUTF8(String string){
        try {
            return string.getBytes("UTF-8");
        } catch (UnsupportedEncodingException e) {
            LOG.warn("Can't encode string with UTF-8, using default: '" + Charset.defaultCharset().name() + "' instead", e);
            return string.getBytes();
        }
    }
}
