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

package com.slaggun.transport;

import junit.framework.TestCase;

/**
 * @author Dmitry Brazhnik (amid.ukr@gmail.com)
 */
public class Timeout {
	private long startTime;
	private long duration;
	private String message = "Timeout exceed fail";

	public Timeout(String message, long duration) {
		this.message = "Timeout exceeds " + duration + " : " + message;
		start(duration);
	}

	public Timeout(long duration) {
		start(duration);		
		this.duration = duration;
	}

	public void start(long duration){
		this.startTime = System.currentTimeMillis();
		this.duration = duration;
	}

	public void assertExceed(){
		if(System.currentTimeMillis() - startTime > duration){
			TestCase.fail(message);
		}
	}
}
