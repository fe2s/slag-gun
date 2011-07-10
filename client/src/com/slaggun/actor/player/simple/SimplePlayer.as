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

package com.slaggun.actor.player.simple {
import com.slaggun.Game;
import com.slaggun.GameEvent;
import com.slaggun.GameEvent;
import com.slaggun.Global;
import com.slaggun.actor.base.AbstractActor;
import com.slaggun.actor.base.Actor;
import com.slaggun.actor.player.simple.presentation.GunWeapon;
import com.slaggun.actor.player.simple.presentation.SimplePlayerPresentation;
import com.slaggun.actor.player.simple.presentation.TrianglesPresentation;
import com.slaggun.actor.bullet.pistol.PistolBulletFactory;
import com.slaggun.events.SimpleActorSnapshot;
import com.slaggun.events.UpdateActorSnapshot;
import com.slaggun.geom.Circle;
import com.slaggun.log.Logger;
import com.slaggun.shooting.Bullet;
import com.slaggun.shooting.HitObject;

import flash.display.BitmapData;
import flash.geom.Point;

/**
 * This is the first implementation of user controlled game character
 *
 * Author Dmitry Brazhnik (amid.ukr@gmail.com)
 *
 * @see Actor
 */
public class SimplePlayer extends AbstractActor implements Actor, HitObject {

    private var log:Logger = Logger.getLogger(SimplePlayerModel);

    private var serverModel:SimplePlayerModel;

    private var presentation:PlayerPresentation;
    private var weapon:Weapon;

    public function SimplePlayer() {
        _model = new SimplePlayerModel();
        weapon = new GunWeapon();
    }

    override public function onInit(event:GameEvent):void {
        respawn(event);
    }

    public function boundHit(event:GameEvent, bullet:Bullet):Boolean {
        var hit:Boolean = new Circle(SimplePlayerModel(model).position, presentation.hitRadius)
                .isInside(bullet.position);
        if(hit && mine){
            this.hit(event, bullet.damage);
        }
        return hit;
    }

    //--------------------------------------------------------
    //---------------------  ACTOR API -----------------------
    //--------------------------------------------------------

    /**
     * Hit player (decrease health)
     * @param hitPoints
     * @return true if still live, false if person has died  :)
     */
    public function hit(event:GameEvent, hitPoints:int):void {
        var model:SimplePlayerModel = SimplePlayerModel(_model);

        log.info("damaged " + hitPoints);
        log.info("health " + model.health);

        model.health -= hitPoints;
        if(model.health < 0){
            respawn(event);
        }
    }

    /**
     * Respawn player
     */
    public function respawn(event:GameEvent):void{
        var model:SimplePlayerModel = SimplePlayerModel(_model);

        if(Math.random() > Global.TRIANGLE_RESPAWN_PROBABILITY){
            presentation = new SimplePlayerPresentation();
        }
        else
        {
            var trianglesPresentation:TrianglesPresentation = new TrianglesPresentation();
            presentation = trianglesPresentation;
            weapon       = trianglesPresentation;
        }

        log.info("respawned");
        model.health = Global.ACTOR_MAX_HEALTH_HP;
        model.position = new Point(Math.random() * event.game.mapWidth * 0.8,
                                   Math.random() * event.game.mapHeight / 2);
    }


    public function get maxSpeed():Number{
        return presentation.maxSpeed * Global.DEBUG_SPEED;
    }

    public function lookAt(x:int, y:int, event:GameEvent):void {
        var actorModel:SimplePlayerModel = SimplePlayerModel(model);

        actorModel.look.x = x;
        actorModel.look.y = y;
    }

    public function moveDirection(vx:Number, vy:Number, event:GameEvent):void {
        var v:Number = Math.sqrt(vx * vx + vy * vy) / maxSpeed;

        if(v != 0){
            vx /= v;
            vy /= v;
        }

        velocity(vx, vy, event);
    }

    public function velocity(vx:Number, vy:Number, event:GameEvent):void {

        var v:Number = Math.sqrt(vx * vx + vy * vy);

        if(v > maxSpeed){
            v /= maxSpeed;
            vx /= v;
            vy /= v;
        }

        var actorModel:SimplePlayerModel = SimplePlayerModel(model);

        actorModel.velocity.x = vx;
        actorModel.velocity.y = vy;
    }

    public function shoot(event:GameEvent):void {
        var actorModel:SimplePlayerModel = SimplePlayerModel(model);


        var shellPosition:Point = presentation.weaponMountPoint(actorModel).add(actorModel.position);
        var shellDirection:Point = presentation.weaponDirection(actorModel).clone();
        shellDirection.normalize(weapon.weaponLength);

        shellPosition = shellPosition.add(shellDirection);


        var shell:Actor = new PistolBulletFactory().create(shellPosition, shellDirection);

        event.game.gameActors.add(shell);
    }

    //--------------------------------------------------------
    //----------------  ACTOR GAME METHODS -------------------
    //--------------------------------------------------------

    override public function live(event:GameEvent):void {
        var world:Game = event.game;
        world.shootingService.addHitObject(this);
        if(replicable){
            world.gameActors.replicate(this);
        }

        var actorModel:SimplePlayerModel = SimplePlayerModel(model);
        if(mine){
            iterateModel(event.elapsedTime, actorModel);

            var radius:int = 15;
            if(actorModel.position.x < -radius ||
               actorModel.position.y < -radius ||
               actorModel.position.x > world.mapWidth  + radius||
               actorModel.position.y > world.mapHeight + radius){
                hit(event, 10);
            }

        }else{
            iterateModel(event.elapsedTime, serverModel);
            clientSpringMove(event.elapsedTime, serverModel, actorModel);
        }
    }

    protected function clientSpringMove(timePass:Number, serverModel:SimplePlayerModel, clientModel:SimplePlayerModel):void{
        var actorX:Number = clientModel.position.x;
        var actorY:Number = clientModel.position.y;

        var serverActorX:Number = serverModel.position.x;
        var serverActorY:Number = serverModel.position.y;

        var vx:Number = (serverActorX - actorX);
        var vy:Number = (serverActorY - actorY);
        var distance:Number = Math.sqrt(vx*vx + vy*vy);
        if(distance != 0){
            vx/=distance;
            vy/=distance;

            var v:Number = distance/10;
            var minSpeed:Number = timePass*maxSpeed;

            if(v < minSpeed){
                v = minSpeed;
            }

            if(v > distance){
                v = distance;
            }

            actorX = vx*v + actorX;
            actorY = vy*v + actorY;

            if(v > timePass * maxSpeed/2){
                clientModel.velocity.x = v*vx/timePass;
                clientModel.velocity.y = v*vy/timePass;
            }else{
                clientModel.velocity.x = serverModel.velocity.x;
                clientModel.velocity.y = serverModel.velocity.y;
            }


            clientModel.position.x = actorX;
            clientModel.position.y = actorY;
        }
    }

    protected function iterateModel(timePass:Number, actorModel:SimplePlayerModel):void{
        var vx:Number = actorModel.velocity.x;
        var vy:Number = actorModel.velocity.y;

        var x:Number = actorModel.position.x;
        var y:Number = actorModel.position.y;


        actorModel.velocity.x = vx;
        actorModel.velocity.y = vy;

        actorModel.position.x = x + vx * timePass;
        actorModel.position.y = y + vy * timePass;
    }

    override public function retrieveUpdateSnapshot(game:Game, snapshot:UpdateActorSnapshot):void {
        var receivedModel:SimplePlayerModel = SimplePlayerModel(SimpleActorSnapshot(snapshot).model);

        var currentPosition:Point;

        var actorModel:SimplePlayerModel = SimplePlayerModel(model);

        if(serverModel == null){
            currentPosition = receivedModel.position.clone();
        }else{
            currentPosition = actorModel.position;
        }

        serverModel = receivedModel;

        actorModel = serverModel.clone();
        actorModel.position = currentPosition;

        model = actorModel;
    }

    //--------------------------------------------------------
    //----------------  ACTOR GAME RENDERER -------------------
    //--------------------------------------------------------

    override public function render(event:GameEvent):void {
        var model:SimplePlayerModel = SimplePlayerModel(model);
        presentation.renderPlayer(event, model);

        var weaponMountPoint:Point = presentation.weaponMountPoint(model);
        weaponMountPoint = weaponMountPoint.add(model.position);
        var weaponDirection:Point = presentation.weaponDirection(model).clone();
        weaponDirection.normalize(1);

        weapon.renderWeapon(event, weaponMountPoint, weaponDirection);
    }
}
}