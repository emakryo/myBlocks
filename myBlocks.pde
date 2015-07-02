class Block{
  int posX, posY;
  color fill_color, str_color;
  int sizeP, sizeQ;
  int id;

  Block(int x, int y, int w, int h, color f, color s, int i){
    posX = x;
    posY = y;
    sizeP = w;
    sizeQ = h;
    fill_color = f;
    str_color = s;
    id = i;
  }

  void draw(boolean[] stubs){
    fill(fill_color);
    stroke(str_color);
    rect(posX, posY, sizeP*scaleX, sizeQ*scaleY);

    for(int s=0; s<sizeP;s++){
      if(stubs[s]){
        rect(posX+(s+0.3)*scaleX, posY-0.25*scaleY,
             0.4*scaleX, 0.25*scaleY);
      }
    }
  }

}

class NormalBlock extends Block{
  int posP = -1, posQ = -1;
  int initX, initY;

  NormalBlock(int x, int y, int w, int h, int i){
    super(x,y,w,h,#ffffff, #7f7f7f,i);
    initX = x;
    initY = y;
  }

  void draw(){
    boolean[] stubs = new boolean[sizeP];
    for(int s=0; s<sizeP; s++){
      if(posQ > 0 && field[posP+s][posQ-1] >= 0){
        stubs[s] = false;
      }
      else{
        stubs[s] = true;
      }
    }
    super.draw(stubs);
  }

  boolean onField(){
    return posP >= 0;
  }

  void select(){
    fill_color = #ff0000;
  }

  void cancel(){
    fill_color = #ffffff;
  }

  void init(){
    // set initial position

    if(!this.onField()){
      return;
    }
    for(int i=0; i<sizeP; i++){
      for(int j=0; j<sizeQ;j++){
        field[posP+i][posQ+j] = -1;
      }
    }
    posX = initX;
    posY = initY;
    posP = -1;
    posQ = -1;

  }

  int put(){
    // return value
    // 0 : success
    // -1 : failure

    // calculate nearest index
    int p = round(float(mouseX-sizeP*scaleX/2) / float(scaleX));
    int q = round(float(mouseY-sizeQ*scaleY/2) / float(scaleY));

    // whether it can put
    for(int i=0; i<sizeP; i++){
      for(int j=0; j<sizeQ; j++){
        if(p+i < 0 || rangeP <= p+i ||
           q+j < 0 || rangeQ <= q+j ||
           (field[p+i][q+j] != id && field[p+i][q+j] >= 0)){
          return -1;
        }
      }
    }

    if(this.onField()){
      // remove previous position
      for(int i=0; i<sizeP; i++){
        for(int j=0; j<sizeQ; j++){
          field[posP+i][posQ+j] = -1;
        }
      }
    }

    // change position
    posX = p * scaleX;
    posY = q * scaleY;
    posP = p;
    posQ = q;
    for(int i=0; i<sizeP; i++){
      for(int j=0; j<sizeQ; j++){
        field[posP+i][posQ+j] = id;
      }
    }

    return 0;
  }

  int xCenter(){
    return posX+(sizeP*scaleX)/2;
  }

  int yCenter(){
    return posY+(sizeQ*scaleY)/2;
  }

  void drop(){

    if(!this.onField()){
      return;
    }

    for(int s=0; s<sizeP; s++){
      for(int t=0; t<sizeQ; t++){
        field[posP+s][posQ+t] = -1;
      }
    }

    posQ += 1;
    posY += scaleY;

    for(int s=0; s<sizeP; s++){
      for(int t=0; t<sizeQ; t++){
        field[posP+s][posQ+t] = id;
      }
    }
  }

  boolean connected(Block b){
    if(!this.onField() || !this.onField()){
      return false;
    }

    for(int s=0; s<sizeP; s++){
      for(int t=0; t<sizeQ; t++){
        if(posQ+t>0 && field[posP+s][posQ+t-1] == b.id){
          return true;
        }
        if(posQ+t<rangeQ-1 && field[posP+s][posQ+t+1] == b.id){
          return true;
        }
      }
    }
    return false;
  }

}

class MovingBlock extends Block{

  MovingBlock(){
    super(0,0,0,0,0,0,0);
  }

  void draw(NormalBlock b){
    int p,q;
    boolean[] stubs = new boolean[b.sizeP];

    posX = mouseX - (sizeP*scaleX)/2;
    posY = mouseY - (sizeQ*scaleY)/2;
    p = round(float(posX)/scaleX);
    q = round(float(posY)/scaleY);
    sizeP = b.sizeP;
    sizeQ = b.sizeQ;
    id = b.id;

    if(mouseX > fieldWidth){
      fill_color = color(#483d8b,127);
    }
    else{
      fill_color = color(#ffffff,127);
    }

    str_color = #7f7f7f;

    for(int i=0; i<sizeP; i++){
      stubs[i] = true;
      for(int j=0; j<sizeQ; j++){
        if((0 <= p+i && p+i < rangeP &&
            0 <= q+j && q+j < rangeQ &&
            field[p+i][q+j] != id && field[p+i][q+j] >= 0) ||
           p+i < 0 || rangeP <= p+i || q+j < 0 || rangeQ <= q+j){
          str_color = #ff0000;
        }
      }
    }
    super.draw(stubs);
  }
}

class FloorBlock extends Block{

  FloorBlock(){
    super(0, (rangeQ-baseQ)*scaleX, rangeP, baseQ, #228b22, color(127),100);
  }

  void draw(){
    boolean[] stubs = new boolean[sizeP];
    for(int s=0; s<sizeP; s++){
      stubs[s] = true;
    }
    super.draw(stubs);
  }

}

class Button{
  int posX, posY;
  int sizeX, sizeY;
  String str;

  Button(int px, int py, int sx, int sy, String s){
    posX = px;
    posY = py;
    sizeX = sx;
    sizeY = sy;
    str = s;
  }

  boolean clicked(){
    if(posX <= mouseX && mouseX <= posX+sizeX &&
       posY <= mouseY && mouseY <= posY+sizeY){
      return true;
    }
    else{
      return false;
    }
  }

  void draw(){
    fill(#b0e0e6);
    stroke(0);
    rect(posX, posY, sizeX, sizeY);
    textSize(20);
    textAlign(CENTER,CENTER);
    fill(0);
    text(str,posX,posY,sizeX,sizeY);
  }
}

int fieldWidth;
int fieldHeight;
int menuWidth;
int menuHeight;
int scaleX;
int scaleY;
int rangeP;
int rangeQ;

int nBlock;
NormalBlock[] blocks;
FloorBlock floorBlock;
MovingBlock movingBlock;
int[][] field;

int baseQ;
int selecting;
Button reset;
Button drop;

int initBlockOffsetX;
int initBlockOffsetY;
int initBlockScaleY;

int blockCounterOffsetX;

int [] mergeMap;

void setup(){
  rangeP = 30;
  rangeQ = 30;
  scaleX = 20;
  scaleY = 20;
  fieldWidth = rangeP*scaleX;
  fieldHeight = rangeQ*scaleY;
  menuWidth = 200;
  menuHeight = fieldHeight;
  size(fieldWidth+menuWidth,fieldHeight);
  baseQ = 3;
  nBlock = 20;
  blocks= new NormalBlock[nBlock];
  floorBlock = new FloorBlock();

  movingBlock = new MovingBlock();
  selecting = -1;

  initBlockOffsetX = 20;
  initBlockOffsetY = 30;
  initBlockScaleY = 50;
  blockCounterOffsetX = 170;

  // 2 x 1
  for(int i=0; i<6; i++){
    blocks[i] = new NormalBlock(fieldWidth+initBlockOffsetX,
                                initBlockOffsetY, 2, 1, i);
  }
  // 3 x 1
  for(int i=6; i<12; i++){
    blocks[i] = new NormalBlock(fieldWidth+initBlockOffsetX,
                                initBlockOffsetY+initBlockScaleY, 3,1, i);
  }
  // 4 x 1
  for(int i=12; i<16; i++){
    blocks[i] = new NormalBlock(fieldWidth+initBlockOffsetX,
                                initBlockOffsetY+2*initBlockScaleY, 4,1,i);
  }
  // 6 x 1
  for(int i=16; i<20; i++){
    blocks[i] = new NormalBlock(fieldWidth+initBlockOffsetX,
                                initBlockOffsetY+3*initBlockScaleY,6,1,i);
  }

  field = new int[rangeP][rangeQ];
  for(int x=0; x<rangeP; x++){
    for(int y=0; y<rangeQ; y++){
      if(y < rangeQ-baseQ){
        field[x][y] = -1;
      }
      else{
        field[x][y] = floorBlock.id;
      }
    }
  }

  int buttonWidth = 130;
  int buttonHeight = 30;
  reset = new Button(fieldWidth + (menuWidth-buttonWidth)/2, 500,
                     buttonWidth, buttonHeight, "Reset");
  drop = new Button(fieldWidth + (menuWidth-buttonWidth)/2, 550,
                    buttonWidth, buttonHeight, "Drop");

  mergeMap = new int[nBlock];

}

void draw(){
  //grid();
  background(#99ccff);

  floorBlock.draw();

  fill(64);
  noStroke();
  rect(fieldWidth, 0, menuWidth, menuHeight);

  reset.draw();
  drop.draw();

  textSize(18);
  fill(255);
  text("x "+ countUnusedBlocksSizeOf(2,1),
       fieldWidth + blockCounterOffsetX, initBlockOffsetY);
  text("x "+ countUnusedBlocksSizeOf(3,1),
       fieldWidth + blockCounterOffsetX, initBlockOffsetY+initBlockScaleY);
  text("x "+ countUnusedBlocksSizeOf(4,1),
       fieldWidth + blockCounterOffsetX, initBlockOffsetY+2*initBlockScaleY);
  text("x "+ countUnusedBlocksSizeOf(6,1),
       fieldWidth + blockCounterOffsetX, initBlockOffsetY+3*initBlockScaleY);

  for(NormalBlock b : blocks){
    b.draw();
  }

  if(selecting >= 0){
    movingBlock.draw(blocks[selecting]);
  }

}

void grid(){
  stroke(127);
  for(int x=1; x<rangeP; x++){
    line(x*scaleX, 0, x*scaleX, fieldHeight);
  }
  for(int y=1; y<rangeQ; y++){
    line(0,y*scaleY, fieldWidth, y*scaleY);
  }
}

void mousePressed(){
  if(selecting < 0){

    if(reset.clicked()){
      for(NormalBlock b : blocks){
        b.init();
      }
      return;
    }

    if(drop.clicked()){
      dropBlocks();
      return;
    }

    int nearest = nearestBlockIndex();
    if(nearest < 0) return;
    selecting = nearest;
    blocks[nearest].select();
  }
  else{
    if(mouseX > fieldWidth){
      blocks[selecting].init();
      blocks[selecting].cancel();
      selecting = -1;
    }
    else{
      if(blocks[selecting].put() >= 0){
        blocks[selecting].cancel();
        selecting = -1;
      }
    }
  }
}

int nearestBlockIndex(){
  float minDist = dist(blocks[0].xCenter(), blocks[0].yCenter(), mouseX, mouseY);
  int minInd = 0;
  int threshold = scaleY * 3;
  for(int i=1; i<nBlock; i++){
    float d = dist(blocks[i].xCenter(), blocks[i].yCenter(),mouseX, mouseY);
    if(d <= minDist){
      minDist = d;
      minInd = i;
    }
  }
  if(minDist < threshold){
    return minInd;
  }
  else{
    return -1;
  }
}

int countUnusedBlocksSizeOf(int p, int q){
  int c=0;
  for(NormalBlock b: blocks){
    if(b.sizeP == p && b.sizeQ == q &&
       b.posP < 0 && b.posQ < 0){
      c++;
    }
  }
  return c;
}

void dropBlocks(){

  int droppingId;

  for(int i=0; i<nBlock; i++){
    mergeMap[i] = i;
  }

  while(true){
    droppingId = -1;
    mergeBlocks();

    /*
    for(int i=0; i<nBlock; i++){
      println(i + " " + mergeMap[i]);
    }
    */

    // find dropable blocks
    for(NormalBlock b: blocks){
      if(b.onField() && mergeMap[b.id] < floorBlock.id){
        droppingId = mergeMap[b.id];
        break;
      }
    }

    if(droppingId < 0){
      break;
    }

    // drop
    for(int j=rangeQ-baseQ-1; j>=0; j--){
      for(int i=0; i<rangeP; i++){
        if(field[i][j] >= 0 && mergeMap[field[i][j]] == droppingId){
          blocks[field[i][j]].drop();
        }
      }
    }

  }

}

void mergeBlocks(){
  boolean changed = true;

  for(NormalBlock b: blocks){
    if(b.onField() && b.connected(floorBlock)){
      mergeMap[b.id] = floorBlock.id;
    }
  }

  while(changed){
    changed = false;

    for(NormalBlock b1: blocks){
      for(NormalBlock b2: blocks){
        if(b1.onField() && b2.onField() &&
           b1.id != b2.id && b1.connected(b2)){
          if(mergeMap[b1.id] > mergeMap[b2.id]){
            mergeMap[b2.id] = mergeMap[b1.id];
            changed = true;
          }
          else if(mergeMap[b1.id] < mergeMap[b2.id]){
            mergeMap[b1.id] = mergeMap[b2.id];
            changed = true;
          }
        }
      }
    }
  }

}
