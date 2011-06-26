/* Copyright 2011 SlagGunTeam
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software distributed under the
 * License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
 * either express or implied. See the License for the specific language governing permissions
 * and limitations under the License.
 */
package com.slaggun.shooting {
import com.slaggun.*;
import com.slaggun.log.Logger;

import mx.logging.Log;

/**
 * @author Dmitry Brazhnik (amid.ukr@gmail.com)
 */
public class ShootingService implements GameService{
    private static const LOG:Logger = Logger.getLogger(ShootingService);

    private var bullets:Array = [];
    private var hitObjects:Array = [];

    public function addBullet(bullet:Bullet):void{
        bullets.push(bullet);
    }

    public function addHitObject(hitObject:HitObject):void{
        hitObjects.push(hitObject);
    }

    private final function processBullet(game:Game, bullet:Bullet):void {
        for (var j:int = 0; j < hitObjects.length; j++) {
            try {
                var hitObject:HitObject = hitObjects[j];
                if (hitObject.boundHit(game, bullet)) {
                    bullet.scored(game, hitObject);
                    return;
                }
            } catch(e:Error) {
                LOG.throwError("Can't process bullet " + bullet + " with hit object " + hitObject, e);
            }
        }
    }

    public function invoke(game:Game):void {

        for(var i:int = 0; i < bullets.length; i++)
        {
            processBullet(game, bullets[i]);
        }

        bullets.length    = 0;
        hitObjects.length = 0;
    }
}
}
