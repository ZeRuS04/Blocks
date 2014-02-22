var db;
var width, height, level;
var blocks = [];
var starC = [1,2,3,4,5,6,7,8,9,10,
             1,2,3,4,5,6,7,8,9,11,
             1,2,3,4,5,7,8,9,11,13,
             1,2,4,5,7,9,10,12,14,16]
//var chgDir = [];
var starCnt =[];
var timers = [];
var stars = [];
var timersS= [];
var startX, startY;
var oldX, oldY;
var cof = 0.9;
var fl=false;


/********************************************
   Инициализация переменных ширины и высоты

 ********************************************/
function initial(w, h, l){
    width=w;
    height=h;
    level=l;
    if(!fl){
        var ins = []
        var inT = []
        for(var y = 0; y < 7; y++)
        {
            timersS[y] = inT;
            stars[y] = ins;
        }
        fl = true;
    }



}
/********************************************
    Получение случайного целого числа
 ********************************************/
// использование Math.round() даст неравномерное распределение!
function getRandomInt(min, max){
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

/********************************************
    Получение случайной булевой переменной
 ********************************************/
function getRandomBool(){
    if(getRandomInt(1,10)>5)
        return true;
    else
        return false;
}


function setStarPos(){

    var strCnt4 = [];

    strCnt4[0] = [0, 0, 0, 1];
    strCnt4[1] = [0, 0, 0, 2];
    strCnt4[2] = [0, 0, 1, 2];
    strCnt4[3] = [0, 0, 1, 3];
    strCnt4[4] = [0, 0, 2, 3];
    strCnt4[5] = [0, 1, 2, 3];
    strCnt4[6] = [0, 1, 2, 4];
    strCnt4[7] = [0, 1, 3, 4];
    strCnt4[8] = [0, 2, 3, 4];
    strCnt4[9] = [1, 2, 3, 4];
    starCnt[4] = strCnt4;

    var strCnt5 = [];
    strCnt5[0] = [0, 0, 0, 0, 1]
    strCnt5[1] = [0, 0, 0, 0, 2]
    strCnt5[2] = [0, 0, 0, 1, 2]
    strCnt5[3] = [0, 0, 0, 1, 3]
    strCnt5[4] = [0, 0, 0, 2, 3]
    strCnt5[5] = [0, 0, 1, 2, 3]
    strCnt5[6] = [0, 0, 1, 2, 4]
    strCnt5[7] = [0, 0, 1, 3, 4]
    strCnt5[8] = [0, 0, 2, 3, 4]
    strCnt5[9] = [1, 1, 2, 3, 4]
    starCnt[5] = strCnt5;

    var strCnt6 = [];
    strCnt6[0] = [0, 0, 0, 0, 0, 1]
    strCnt6[1] = [0, 0, 0, 0, 0, 2]
    strCnt6[2] = [0, 0, 0, 0, 1, 2]
    strCnt6[3] = [0, 0, 0, 0, 1, 3]
    strCnt6[4] = [0, 0, 0, 0, 2, 3]
    strCnt6[5] = [0, 0, 1, 1, 2, 3]
    strCnt6[6] = [0, 0, 1, 1, 2, 4]
    strCnt6[7] = [0, 0, 1, 1, 3, 4]
    strCnt6[8] = [0, 0, 2, 2, 3, 4]
    strCnt6[9] = [1, 1, 2, 2, 3, 4]
    starCnt[6] = strCnt6;

    var strCnt7 = [];
    strCnt7[0] = [0, 0, 0, 0, 0, 0, 1]
    strCnt7[1] = [0, 0, 0, 0, 0, 0, 2]
    strCnt7[2] = [0, 0, 0, 0, 1, 1, 2]
    strCnt7[3] = [0, 0, 0, 0, 1, 1, 3]
    strCnt7[4] = [0, 0, 0, 0, 2, 2, 3]
    strCnt7[5] = [0, 0, 1, 1, 2, 2, 3]
    strCnt7[6] = [0, 0, 1, 1, 2, 2, 4]
    strCnt7[7] = [0, 0, 1, 1, 3, 3, 4]
    strCnt7[8] = [0, 0, 2, 2, 3, 3, 4]
    strCnt7[9] = [1, 1, 2, 2, 3, 3, 4]
    starCnt[7] = strCnt7;
}

/********************************************
    Сохранение указателей на блоки
 ********************************************/

function saveBlocks(block, timer, index){
    blocks[index] = block;
    timers[index] = timer;
}

/********************************************
    Сохранение указателей на звезды
 ********************************************/

function saveStars(star, timer, index, stg){

    if(!fl){
        for(var y = 0; y < 7; y++)
        {
            timersS[y] = [];
            stars[y] = [];
        }
        fl = true;
    }
    var b = stars[stg];
    var bt = timersS[stg];

    b[index]=star
    bt[index]=timer

    stars[stg] =b;
    timersS[stg] =bt;
}

/********************************************
    Старт уровня
 ********************************************/
function startLevel(nextL, stage, player, lay, level){

    level = nextL;
    var l = nextL%10;
    if(l === 0)
         l = 10;
    player.x = width/2 - player.width/2;
    player.y = 0;
    player.source = "image/playerB.png"

    for(var i=0; i<stage; i++)
    {
        blocks[i].x = getRandomInt(0, width-blocks[i].width);
        timers[i].start();
    }

    for(var k=0; k<stage; k++)
    {
        for(var j=0; j<starCnt[stage][l-1][k]; j++)
        {
            stars[k][j].width = lay/2
            stars[k][j].visible = true;
            timersS[k][j].start();
        }
    }

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
function move(block, dirChanged) {
    if(((block.rightX) > width)||(block.leftX < 0))
        if(!dirChanged)
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


function playerMoveX(player, sceneX, sceneY, lay){


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
               var dirChanged = false;
               if((oldDir !== player.direction)&&(blocks[i].fickle)&&
                  (player.y >= lay)&&(player.y <= (height-10))){
                   changeDir(blocks[i]);
                   dirChanged = true;
               }
               if((player.y >= lay)&&(player.y <= (height-10)))
                   move(blocks[i], dirChanged);
           }
       }
   }

}

function playerMoveY(player, sceneX, sceneY, lay){


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

           if((((player.y+lay*normY)>= 0)&&((player.y+lay*normY)<= (height-10)))&&!isCrashed(player, lay, normY))
                player.y += lay*normY;

       }
   }

}
function isCrashed(player, lay, normY)
{
    for(var i=0; i<blocks.length; i++)
    {
        if(Math.abs(player.y+lay*normY-blocks[i].parent.y)<10)
        {
            if((player.rightX >= blocks[i].rightX)&&(player.leftX <= blocks[i].leftX)||
               (player.rightX >= blocks[i].leftX)&&(player.rightX <= blocks[i].rightX)||
               (player.leftX <= blocks[i].rightX)&&(player.leftX >= blocks[i].leftX)    )
                    return true;
        }
    }
    return false;
}

function isCrash(player, block, timer, dialog){
    if((player.rightX >= block.rightX)&&(player.leftX <= block.leftX)||
       (player.rightX >= block.leftX)&&(player.rightX <= block.rightX)||
       (player.leftX <= block.rightX)&&(player.leftX >= block.leftX))
    {
        dialog.open();
        return true;
    }
    else
        return false;
}



function findStar(player, star, lay){

    if((player.rightX >= star.rightX)&&(player.leftX <= star.leftX)||
       (player.leftX <= star.rightX)&&(player.leftX >= star.leftX) ||
       (player.rightX <= star.rightX)&&(player.rightX >= star.leftX) )
    {
        star.visible = false;
//        star.x = lay/3+20;
//        star.y = lay/2+(lay/2 - star.height)/2;
        return true;
    }
    return false;
}
