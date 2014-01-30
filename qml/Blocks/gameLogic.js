var width, height;
function initial(w, h, rep, count){
    width=w;
    height=h;
}

// использование Math.round() даст неравномерное распределение!
function getRandomInt(min, max)
{
  return Math.floor(Math.random() * (max - min + 1)) + min;
}



var blockTimers = [];
function saveTimer(timer, out){
    blockTimers.push(timer)
}



function chageDir(block){
    if(block.direction)
        block.direction = false;
    else
        block.direction = true;
}

function move(block, level, right) {
    if(((block.rightX) > right)||(block.leftX < 0))
        chageDir(block);

    if(block.direction)
        block.x = block.x+block.speed*level;
    else
        block.x = block.x-block.speed*level;

}

var startX, startY;
var oldX, oldY

function setStartP(point){
    startX = point.sceneX;
    startY = point.sceneY;
    oldX = point.sceneX;
    oldY = point.sceneY;
}


function setOldP(point)
{
    oldX = point.sceneX;
    oldY = point.sceneY;
}


function playerMoveX(player, sceneX, sceneY, lay, out){


   var dX = (sceneX - oldX);
   var dY = (sceneY - oldY);
//   out.text = "dX,dY: "+ dX +","+ dY+"; sX,sY: " +startX +","+startY;

   if(Math.abs(dX) > Math.abs(dY))
   {
       var normX = dX/Math.abs(dX);
       if(normX > 0)
           player.source = "image/playerR.png"
       else
           player.source = "image/playerL.png"
       var step = 6*normX

       if(((player.leftX+step)> 0)&&((player.rightX+step/*+player.width*/)< width))
            player.x += step;
   }

}

function playerMoveY(player, sceneX, sceneY, lay, out){


   var dX = (sceneX - startX);
   var dY = (sceneY - startY);
//   out.text = "dX,dY: "+ dX +","+ dY+"; sX,sY: " +startX +","+startY;

   if(Math.abs(dX) < Math.abs(dY))
   {
       if(Math.abs(dY) > 50)
       {
           var normY = dY/Math.abs(dY);
           if(normY > 0)
               player.source = "image/playerB.png"
           else
               player.source = "image/playerT.png"
           if(((player.y+lay*normY)>= 0)&&((player.y+lay*normY)<= (height-10)))
                player.y += lay*normY;
       }
   }

}

function isCrash(player, block, timer, out){
    if((player.rightX >= block.leftX)&&(player.rightX <= block.rightX)||
       (player.leftX <= block.rightX)&&(player.leftX >= block.leftX)    )
    {
        out.text = "Геймовер!!!МУХАХАХа"
        for(var i = 0; i<blockTimers.length; i++)
            blockTimers[i].stop();

    }
    else
    {
        out.text = "Все нормуль, братюнь"
    }

}
