var width, height, level;
var blocks = [];
//var chgDir = [];
var timers = [];
var stars = [];
var timersS= [];
var startX, startY;
var oldX, oldY
var cof = 0.9;
var nextX = 5;



/********************************************
   Инициализация переменных ширины и высоты

 ********************************************/
function initial(w, h, l){
    width=w;
    height=h;
    level=l;
}
/********************************************
    Получение случайного целого числа
 ********************************************/
// использование Math.round() даст неравномерное распределение!
function getRandomInt(min, max)
{
  return Math.floor(Math.random() * (max - min + 1)) + min;
}
/********************************************
    Получение случайной булевой переменной
 ********************************************/
function getRandomBool()
{
    if(getRandomInt(1,10)>5)
        return true;
    else
        return false;
}

/********************************************
    Сохранение указателей на блоки
 ********************************************/

function saveBlocks(block, timer, out){
    blocks.push(block);
    timers.push(timer)
}

/********************************************
    Сохранение указателей на звезды
 ********************************************/

function saveStars(star, timer, index, out){
    stars[index] = star;
    timersS[index] = timer;

}

/********************************************
    Старт уровня
 ********************************************/
function startLevel(nextL, stage, player, lay, out){

    level = nextL;
    player.x = width/2 - player.width/2;
    player.y = 0;
    player.source = "image/playerB.png"
    nextX = 0;

    for(var i=0; i<blocks.length; i++)
    {
        blocks[i].x = getRandomInt(0, width-blocks[i].width);
        timers[i].start();
    }

    for(var j=0; j<stars.length; j++)
    {
        stars[j].width = lay/2
        stars[j].y = lay*getRandomInt(2, stage+1)+(lay-stars[j].height)/2
        stars[j].x = getRandomInt(0, width-stars[j].width);
        timersS[j].start();
    }

    return nextL;

}

/********************************************
    Смена направления движения блоков
 ********************************************/
function changeDir(block){
    if(block.direction)
        block.direction = false;
    else
        block.direction = true;
}

/********************************************
    Перемещение блока(блок*, уровеньИгры,

                            правыйКрайПоля)
 ********************************************/
function move(block) {
    if(((block.rightX) > width)||(block.leftX < 0))
        changeDir(block);

    if(block.direction)
        block.x = block.x+block.speed*level;
    else
        block.x = block.x-block.speed*level;

}


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

   var oldDir = player.direction;

   if(Math.abs(dX) > Math.abs(dY))
   {
       var normX = dX/Math.abs(dX);
       if(normX > 0){
           player.source = "image/playerR.png";
           player.direction = true;
       }
       else{
           player.source = "image/playerL.png"
           player.direction = false;
       }
//       if(oldDir !== player.direction)
//           for(var j=0; j<blocks.length; j++)
//                chgDir[j] = true;

       var step = 7*normX
       if(((player.leftX+step)> 0)&&((player.rightX+step)< width))
       {
           player.x += step;
           for(var i=0; i<blocks.length; i++)
           {
               if((oldDir !== player.direction)&&(blocks[i].fickle)&&
                  (player.y >= lay)&&(player.y <= (height-10)))
                   changeDir(blocks[i]);

               move(blocks[i]);
           }
       }
   }

}

function playerMoveY(player, sceneX, sceneY, lay, out){


   var dX = (sceneX - startX);
   var dY = (sceneY - startY);

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
        return true;
    }
    else
    {
        out.text = "Все нормуль, братюнь"
        return false;
    }
}



function findStar(player, star, lay, starCount, out){

    if((player.rightX >= star.rightX)&&(player.leftX <= star.leftX)||
       (player.leftX <= star.rightX)&&(player.leftX >= star.leftX) ||
       (player.rightX <= star.rightX)&&(player.rightX >= star.leftX) )
    {

        while(out.width < (starCount*(star.width*cof+5)))
            cof *= 0.9;

        star.width *= cof;
        star.x = nextX;
        nextX += star.width*cof+5;
        star.y = lay/2+(lay/2 - star.height)/2;
        return true;
    }
    return false;
}
