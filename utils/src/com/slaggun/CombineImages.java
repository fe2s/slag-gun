/*
 * Copyright 2010 SlagGunTeam
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software distributed under the
 * License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
 * either express or implied. See the License for the specific language governing permissions
 * and limitations under the License.
 */

package com.slaggun;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.awt.*;
import java.io.File;
import java.io.IOException;
import java.io.FilenameFilter;
import java.util.Arrays;

/**
 * @author Dmitry Brazhnik (amid.ukr@gmail.com)
 */
public class CombineImages {
	public static void main(String[] args) throws IOException {

		File dir = new File(".");
		File[] images = dir.listFiles(new FilenameFilter() {
			public boolean accept(File dir, String name) {
				return name.endsWith(".png");
			}
		});
		Arrays.sort(images);


        BufferedImage first = ImageIO.read(images[0]);

		BufferedImage result = new BufferedImage(
                               images.length * (first.getWidth() + 1), first.getHeight(), //work these out
                               BufferedImage.TYPE_INT_ARGB);
        Graphics g = result.getGraphics();



		int x = 0;

		System.out.println("----------");
		for(File image : images){
			System.out.println("Reading: " + image.getPath());
            BufferedImage bi = ImageIO.read(image);
            g.drawImage(bi, x, 0, null);
            x += 104;
        }
		System.out.println("----------");



		ImageIO.write(result, "png", new File("../result.png"));

		System.out.println("Done");
	}
}
