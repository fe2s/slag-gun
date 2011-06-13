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

import java.util.Map;
import java.util.HashMap;
import java.util.Iterator;
import java.util.concurrent.ConcurrentHashMap;

/**
 * @author Dmitry Brazhnik (amid.ukr@gmail.com)
 */
public class CollectionTest {

	private static void test(Map<String, Object> obj){
		System.out.println("Test: " + obj.getClass().getSimpleName());
		try{
			obj.put("number", 2);
			obj.put("user", "root");
			obj.put("object", new Object());

			System.out.println("first cycle");
			for (String key : obj.keySet()) {
				obj.put(key + " clone", obj.get(key));
				System.out.println(key + " -> " + obj.get(key));
			}

			System.out.println("-----------------------");
			System.out.println("second cycle");

			for (String key : obj.keySet()) {
				System.out.println(key + " -> " + obj.get(key));
			}

			System.out.println("-----------------------");
			System.out.println("third cycle");
			int i=0;

			Iterator<String> iterator = obj.keySet().iterator();

			//iterator.next();
			//iterator.next();

			iterator.next();
			iterator.next();

			for (String key : obj.keySet()) {
				//obj.put(key + " clone", obj.get(key));
				String iter = null;

				if(iterator.hasNext()){
					iter = iterator.next();
				}

				boolean remove = /*(i++ & 1) == 0 &&*/ iter != null;
				if(remove){
					System.out.print("remove: ");
				}

				System.out.println(key + " -> " + obj.get(key));

				if(remove){
					iterator.remove();
				}
			}

			System.out.println("-----------------------");
			System.out.println("fourth cycle");
			for (String key : obj.keySet()) {
				System.out.println(key + " -> " + obj.get(key));
			}
		}catch (Exception e){
			e.printStackTrace();
		}finally {
			System.out.println("end test");
			System.out.println("-----------------------");
			System.out.println();
		}
	}

	public static void main(String[] args) {
		//test(new HashMap<String,  Object>());
		test(new ConcurrentHashMap<String, Object>());
	}
}
