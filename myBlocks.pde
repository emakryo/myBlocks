import ddf.minim.*;

class Block{
  int posX, posY;
  color fillColor, strColor;
  int sizeP, sizeQ;
  int id;

  Block(int x, int y, int w, int h, color f, color s, int i){
    posX = x;
    posY = y;
    sizeP = w;
    sizeQ = h;
    fillColor = f;
    strColor = s;
    id = i;
  }

  void draw(){
    boolean[] stubs = new boolean[sizeP];
    for(int i=0; i<stubs.length; i++){
      stubs[i] = true;
    }
    draw(stubs);
  }

  void draw(boolean[] stubs){
    fill(fillColor);
    stroke(strColor);
    rect(posX, posY, sizeP*scaleX, sizeQ*scaleY);

    for(int s=0; s<sizeP;s++){
      if(stubs[s]){
        rect(posX+(s+0.3)*scaleX, posY-0.25*scaleY,
             0.4*scaleX, 0.25*scaleY);
      }
    }
  }

  void draw(boolean[] stubs, int offsetX, int offsetY, color s, color f){
    Block b = new Block(posX+offsetX, posY+offsetY, sizeP, sizeQ, s, f, id);
    b.draw(stubs);
  }

  int centerX(){
    return posX+(sizeP*scaleX)/2;
  }

  int centerY(){
    return posY+(sizeQ*scaleY)/2;
  }

  boolean pointing(){
    return posX <= mouseX && mouseX < posX+sizeP*scaleX &&
           posY <= mouseY && mouseY < posY+sizeQ*scaleY;
  }

}

class NormalBlock extends Block{
  int posP = -1, posQ = -1;
  int initX, initY;
  boolean selecting = false;
  boolean floating = false;

  NormalBlock(int x, int y, int w, int h, int i){
    super(x,y,w,h,#ffffff, #7f7f7f,i);
    initX = x;
    initY = y;
  }

  void draw(boolean[] stubs, int T){
    if(selecting){
      fillColor = #ff0000;
    }
    else if(floating){
      fillColor = color(255,T,T);
    }
    else{
      fillColor = #ffffff;
    }
    draw(stubs);
  }

  boolean onField(){
    return posP >= 0;
  }

  void select(){
    selecting = true;
  }

  void cancel(){
    selecting = false;
  }

  void init(){
    // set initial position

    if(!this.onField()){
      return;
    }
    posX = initX;
    posY = initY;
    posP = -1;
    posQ = -1;

    floating = false;
    selecting = false;
  }

  void move(int p, int q){
    posX = p * scaleX;
    posY = q * scaleY;
    posP = p;
    posQ = q;
  }

}

class FloorBlock extends Block{

  FloorBlock(int floorQ){
    super(0, rangeQ*scaleX, rangeP, floorQ, #228b22, color(127),100);
  }

  void draw(){
    boolean[] stubs = new boolean[sizeP];
    for(int s=0; s<sizeP; s++){
      stubs[s] = true;
    }
    super.draw(stubs);
  }

}

class NormalBlocks{
  NormalBlock[] blocks;
  IntDict sizeIndeces;
  boolean[] selecting;
  int[][] field;
  Block[] skelton = {};

  int initBlockOffsetX = 20;
  int initBlockOffsetY = 30;
  int initBlockScaleY = 50;
  int blockCounterOffsetX = 170;

  NormalBlocks(int[] ws, int[] hs){
    int len = ws.length;
    int sizeIndex = 0;
    blocks = new NormalBlock[len];
    sizeIndeces = new IntDict();
    selecting = new boolean[len];

    for(int i=0; i<len; i++){
      String sizeStr = ws[i]+" "+hs[i];
      if(! sizeIndeces.hasKey(sizeStr)){
        Block b = new Block(fieldWidth + initBlockOffsetX,
                            initBlockOffsetY +
                            sizeIndex*initBlockScaleY,
                            ws[i],hs[i], color(64), #7f7f7f, sizeIndex);
        skelton = (Block [])append(skelton, b);
        sizeIndeces.set(sizeStr, sizeIndex++);
      }
      blocks[i] = new NormalBlock(fieldWidth + initBlockOffsetX,
                                  initBlockOffsetY +
                                  sizeIndeces.get(sizeStr)*initBlockScaleY,
                                  ws[i], hs[i], i);
      selecting[i] = false;
    }

    field = new int[rangeP][rangeQ];
    for(int x=0; x<rangeP; x++){
      for(int y=0; y<rangeQ; y++){
        field[x][y] = -1;
      }
    }
  }

  void draw(){
    int T = int((sin(millis()*PI/2000)+1.0)*64+127);
    for(NormalBlock b: blocks){
      b.draw(stubs(b.id), T);
    }
  }

  void drawCount(){
    int[] count = new int[sizeIndeces.size()];
    for(NormalBlock b: blocks){
      if(! b.onField()){
        count[sizeIndeces.get(b.sizeP+" "+b.sizeQ)] += 1;
      }
    }

    for(int s=0; s < count.length; s++){
      textSize(18);
      fill(255);
      text("x "+ count[s],
           fieldWidth + blockCounterOffsetX,
           initBlockOffsetY + s*initBlockScaleY);
      skelton[s].draw();
    }
  }

  void drawSelecting(){
    int centerX = centerX();
    int centerY = centerY();
    color strColor = #7f7f7f;
    color fillColor = color(#ffffff,127);

    if(centerX < 0 || centerY < 0) return;

    if(!isPuttable()){
      strColor = #ff0000;
    }

    if(mouseX > fieldWidth){
      fillColor = color(#2f4f4f, 127);
    }

    for(NormalBlock b: blocks){
      if(selecting[b.id]){
        b.draw(stubsSelecting(b.id),
               mouseX-centerX,mouseY-centerY,
               fillColor, strColor);
      }
    }
  }

  void drawDropped(){
  }

  boolean[] stubs(int id){
    NormalBlock b = blocks[id];
    boolean[] st = new boolean[b.sizeP];
    for(int s = 0; s < b.sizeP; s++){
      if(! b.onField()) st[s] = true;
      else if(b.posQ == 0) st[s] = true;
      else if(field[b.posP+s][b.posQ-1] < 0) st[s] = true;
      else st[s] = false;
    }
    return st;
  }

  boolean[] stubsSelecting(int id){
    NormalBlock b = blocks[id];
    boolean[] st = new boolean[b.sizeP];
    for(int s = 0; s < b.sizeP; s++){
      if(! b.onField()) st[s] = true;
      else if(b.posQ == 0) st[s] = true;
      else if(field[b.posP+s][b.posQ-1] < 0) st[s] = true;
      else if(!selecting[field[b.posP+s][b.posQ-1]]) st[s] = true;
      else st[s] = false;
    }
    return st;
  }

  void init(int id){
    NormalBlock b = blocks[id];
    if(! b.onField()) return;
    for(int s=0; s<b.sizeP; s++){
      for(int t=0; t<b.sizeQ; t++){
        field[b.posP+s][b.posQ+t] = -1;
      }
    }
    b.init();
  }

  void initSelecting(){
    for(NormalBlock b: blocks){
      if(selecting[b.id]){
        init(b.id);
        selecting[b.id] = false;
      }
    }
  }

  void resetAll(){
    for(NormalBlock b: blocks){
      b.cancel();
      init(b.id);
    }
  }

  int nearestIndex(int x, int y){

    float minDist = dist(blocks[0].centerX(), blocks[0].centerY(), x, y);
    int minInd = 0;
    int threshold = scaleY * 3;
    for(int i=1; i<blocks.length; i++){
      float d = dist(blocks[i].centerX(), blocks[i].centerY(),x,y);
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

  void select(int id){
    blocks[id].select();
    selecting[id] = true;
  }

  void select(boolean[] mask){
    for(NormalBlock b: blocks){
      if(mask[b.id]){
        select(b.id);
      }
    }
  }

  void selectNearest(){
    for(NormalBlock b: blocks){
      if(b.pointing()){
        select(b.id);
        return;
      }
    }
    int i = nearestIndex(mouseX, mouseY);
    if(i < 0) return;
    select(i);
  }

  boolean[] adjacent(int id){
    NormalBlock b = blocks[id];
    boolean[] ad = new boolean[blocks.length];
    for(int i=0; i<blocks.length; i++){
      ad[i] = false;
    }

    for(int s=0; s<b.sizeP; s++){
      if(b.posQ > 0){
        int n = field[b.posP+s][b.posQ-1];
        if(0 <= n && n < blocks.length){
          ad[n] = true;
        }
      }
      if(b.posQ+b.sizeQ < rangeQ){
        int n = field[b.posP+s][b.posQ+b.sizeQ];
        if(0 <= n && n < blocks.length){
          ad[n] = true;
        }
      }

    }
    return ad;
  }

  void expand(){
    boolean changed = true;

    while(changed){
      changed = false;

      for(NormalBlock b: blocks){
        if(selecting[b.id]){
          boolean[] ad = adjacent(b.id);

          for(int i=0; i<blocks.length;i++){
            if(!selecting[i] && ad[i]){
              select(i);
              changed = true;
            }
          }
        }
      }
    }

  }

  void cancel(){
    for(int i=0; i<blocks.length; i++){
      blocks[i].cancel();
      selecting[i] = false;
    }
  }

  int centerX(){
    int x=0,n=0;
    for(NormalBlock b:blocks){
      if(selecting[b.id]){
        x += b.centerX();
        n ++;
      }
    }
    return n != 0 ? x/n : -1;
  }

  int centerY(){
    int y=0,n=0;
    for(NormalBlock b:blocks){
      if(selecting[b.id]){
        y += b.centerY();
        n ++;
      }
    }
    return n != 0 ? y/n : -1;
  }

  boolean isPuttable(){
    int cx = centerX();
    int cy = centerY();

    for(NormalBlock b: blocks){
      if(! selecting[b.id]) continue;

      int p = round(float(mouseX-cx+b.centerX()-b.sizeP*scaleX/2) / float(scaleX));
      int q = round(float(mouseY-cy+b.centerY()-b.sizeQ*scaleY/2) / float(scaleY));

      for(int s=0; s<b.sizeP; s++){
        for(int t=0; t<b.sizeQ; t++){
          if(p+s < 0 || rangeP <= p+s ||
             q+t < 0 || rangeQ <= q+t ||
             (field[p+s][q+t] >= 0 && !selecting[field[p+s][q+t]])){
            return false;
          }
        }
      }
    }
    return true;
  }

  boolean isSelecting(){
    boolean s = false;
    for(int i=0; i<blocks.length; i++){
      s = s || selecting[i];
    }
    return s;
  }

  int put(){
    int cx,cy;
    if(! isPuttable()) return -1;
    cx = centerX();
    cy = centerY();

    // clear field
    for(int i=0; i<rangeP; i++){
      for(int j=0; j<rangeQ; j++){
        if(0 <= field[i][j] && field[i][j] < blocks.length &&
           selecting[field[i][j]])
          field[i][j] = -1;
      }
    }

    for(NormalBlock b: blocks){
      if(! selecting[b.id]) continue;

      int p = round(float(mouseX-cx+b.centerX()-b.sizeP*scaleX/2) / float(scaleX));
      int q = round(float(mouseY-cy+b.centerY()-b.sizeQ*scaleY/2) / float(scaleY));

      b.move(p,q);

      for(int s=0; s<b.sizeP; s++){
        for(int t=0; t<b.sizeQ; t++){
          field[b.posP+s][b.posQ+t] = b.id;
        }
      }
    }

    cancel();

    checkFloating();

    return 0;
  }

  void checkFloating(){
    boolean changed = true;
    boolean[] floating = new boolean[blocks.length];

    for(NormalBlock b: blocks){
      if(! b.onField() || onGround(b.id)){
        floating[b.id] = false;
      }
      else{
        floating[b.id] = true;
      }
    }

    while(changed){
      changed = false;
      for(NormalBlock b: blocks){
        if(! floating[b.id]) continue;
        boolean[] ad = adjacent(b.id);
        for(NormalBlock ab: blocks){
          if(ad[ab.id] && ! floating[ab.id]){
            floating[b.id] = false;
            changed = true;
          }
        }
      }
    }

    for(NormalBlock b: blocks){
      b.floating = floating[b.id];
    }

  }

  boolean onGround(int id){
    NormalBlock b = blocks[id];
    if(! b.onField()) return false;

    if(b.posQ + b.sizeQ == rangeQ) return true;
    else return false;
  }

  boolean onGround(){
    for(NormalBlock b: blocks){
      if(selecting[b.id] && onGround(b.id)){
        return true;
      }
    }
    return false;
  }

  void dropSelecting(){
    if(onGround()) return;

    for(int i=0; i<rangeP; i++){
      for(int j=0; j<rangeQ; j++){
        if(0 <= field[i][j] && field[i][j] < blocks.length &&
           selecting[field[i][j]]){
          field[i][j] = -1;
        }
      }
    }

    for(NormalBlock b: blocks){
      if(selecting[b.id]){

        b.move(b.posP, b.posQ+1);

        for(int s=0; s<b.sizeP; s++){
          for(int t=0; t<b.sizeQ; t++){
            field[b.posP+s][b.posQ+t] = b.id;
          }
        }
      }
    }
  }


  void dropAll(){

    boolean[] dropped = new boolean[blocks.length];

    for(NormalBlock b: blocks){
      if(! b.onField()){
        dropped[b.id] = true;
      }
      else if(onGround(b.id)){
        dropped[b.id] = true;
      }
      else{
        dropped[b.id] = false;
      }
    }

    while(true){
      boolean finished = true;
      for(int i=0; i<blocks.length; i++){
        selecting[i] = false;
      }
      for(int i=0; i<blocks.length; i++){
        if(! dropped[i]){
          selecting[i] = true;
          finished = false;
          break;
        }
      }
      if(finished) break;

      expand();

      if(onGround()){
        for(int i=0; i<blocks.length; i++){
          dropped[i] = dropped[i] || selecting[i];
        }
      }
      else{
        dropSelecting();
      }

    }

    for(NormalBlock b: blocks){
      b.cancel();
    }

    checkFloating();

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

  boolean pointing(){
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
int floorWidth;
int floorHeight;
int scaleX;
int scaleY;
int rangeP;
int rangeQ;

NormalBlocks blocks;
FloorBlock floorBlock;

Button reset;
Button drop;
Button done;

int lastClick;

Minim minim;
AudioPlayer click, dispose, resetSound;

void setup(){
  int floorQ = 2;
  rangeP = 25;
  rangeQ = 25;
  scaleX = 20;
  scaleY = 20;
  fieldWidth = rangeP*scaleX;
  fieldHeight = rangeQ*scaleY;
  floorWidth = fieldWidth;
  floorHeight = floorQ * scaleY;
  menuWidth = 200;
  menuHeight = fieldHeight + floorHeight;
  size(fieldWidth+menuWidth,menuHeight);

  int[] widths  = {2,2,2,2,2,2,3,3,3,3,3,3,4,4,4,4,6,6,6,6};
  int[] heights = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1};

  blocks= new NormalBlocks(widths,heights);
  floorBlock = new FloorBlock(floorQ);

  int buttonWidth = 130;
  int buttonHeight = 30;
  reset = new Button(fieldWidth + (menuWidth-buttonWidth)/2, height - 110,
                     buttonWidth, buttonHeight, "Reset");
  drop = new Button(fieldWidth + (menuWidth-buttonWidth)/2, height - 60,
                    buttonWidth, buttonHeight, "Drop");

  minim = new Minim(this);
  click = minim.loadFile("sound/click.mp3");
  dispose = minim.loadFile("sound/dispose.mp3");
  resetSound = minim.loadFile("sound/wc.mp3");
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

  blocks.drawCount();

  blocks.draw();

  blocks.drawSelecting();

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
  if(blocks.isSelecting()){
    if(millis() - lastClick < 200){
      blocks.expand();
    }

    // dispose
    else if(mouseX > fieldWidth){
      blocks.initSelecting();
      blocks.cancel();
      dispose.rewind();
      dispose.play();
    }
    else{
      blocks.put();
      click.rewind();
      click.play();
    }

  }
  else{

    if(reset.pointing()){
      blocks.resetAll();
      resetSound.rewind();
      resetSound.play();
      return;
    }
    else if(drop.pointing()){
      blocks.dropAll();
      return;
    }
    else{
      blocks.selectNearest();
      click.rewind();
      click.play();
    }
  }
  lastClick = millis();
}
