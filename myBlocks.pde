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

}

class NormalBlock extends Block{
  int posP = -1, posQ = -1;
  int initX, initY;

  NormalBlock(int x, int y, int w, int h, int i){
    super(x,y,w,h,#ffffff, #7f7f7f,i);
    initX = x;
    initY = y;
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
    posX = initX;
    posY = initY;
    posP = -1;
    posQ = -1;

  }

  void move(int p, int q){
    posX = p * scaleX;
    posY = q * scaleY;
    posP = p;
    posQ = q;
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

class NormalBlocks{
  NormalBlock[] blocks;
  IntDict sizeIndeces;
  boolean[] selecting;

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
        sizeIndeces.set(sizeStr, sizeIndex++);
      }
      blocks[i] = new NormalBlock(fieldWidth + initBlockOffsetX,
                                  initBlockOffsetY +
                                  sizeIndeces.get(sizeStr)*initBlockScaleY,
                                  ws[i], hs[i], i);
      selecting[i] = false;
    }
  }

  void draw(){
    for(NormalBlock b: blocks){
      b.draw(stubs(b.id));
    }
  }

  void drawCount(){
    int[] count = new int[sizeIndeces.size()];
    for(NormalBlock b: blocks){
      if(! b.onField()){
        count[sizeIndeces.get(b.sizeP+" "+b.sizeQ)] += 1;
      }
    }

    textSize(18);
    fill(255);
    for(int s=0; s < count.length; s++){
      text("x "+ count[s],
           fieldWidth + blockCounterOffsetX,
           initBlockOffsetY + s*initBlockScaleY);
    }
  }

  void drawSelecting(){
    int centerX = centerX();
    int centerY = centerY();
    color strColor = #7f7f7f;

    if(centerX < 0 || centerY < 0) return;

    if(!isPuttable()){
      strColor = #ff0000;
    }

    for(NormalBlock b: blocks){
      if(selecting[b.id]){
        b.draw(stubsSelecting(b.id),
               mouseX-centerX,mouseY-centerY,
               color(#ffffff,127),strColor);
      }
    }
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

  void init(){
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
        b.init();
        selecting[b.id] = false;
      }
    }
  }

  void init(int id){
    blocks[id].init();
    for(int i=0; i<rangeP; i++){
      for(int j=0; j<rangeQ; j++){
        if(field[i][j] == id){
          field[i][j] = -1;
        }
      }
    }
  }

  void reset(){
    for(int i=0; i<rangeP; i++){
      for(int j=0; j<rangeQ-baseQ; j++){
        field[i][j] = -1;
      }
    }

    for(NormalBlock b: blocks){
      b.cancel();
      b.init();
    }
  }

  NormalBlock at(int id){
    return blocks[id];
  }

  int count(){
    return blocks.length;
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

  void select(boolean[] mask){
    for(int i=0; i<blocks.length; i++){
      if(mask[i]){
        blocks[i].select();
        selecting[i] = true;
      }
    }
  }

  void select(int id){
    blocks[id].select();
    selecting[id] = true;
  }

  void selectNearest(){
    int i = nearestIndex(mouseX, mouseY);

    if(i < 0) return;

    select(i);
  }

  boolean[] adjust(int id){
    NormalBlock b = blocks[id];
    boolean[] ad = new boolean[blocks.length];
    for(int i=0; i<blocks.length; i++){
      ad[i] = false;
    }

    for(int s=0; s<b.sizeP; s++){
      int n = field[b.posP+s][b.posQ-1];
      if(0 <= n && n < blocks.length){
        ad[n] = true;
      }
      n = field[b.posP+s][b.posQ+b.sizeQ];
      if(0 <= n && n < blocks.length){
        ad[n] = true;
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
          boolean[] ad = adjust(b.id);

          for(int i=0; i<blocks.length;i++){
            if(!selecting[i] && ad[i]){
              selecting[i] = true;
              changed = true;
            }
          }
        }
      }
    }

    for(NormalBlock b: blocks){
      if(selecting[b.id]){
        b.select();
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
             field[p+s][q+t] == floorBlock.id ||
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

      b.cancel();
      selecting[b.id] = false;
    }

    return 0;
  }

  boolean onGround(int id){
    NormalBlock b = blocks[id];
    if(! b.onField()) return false;

    if(b.posQ + b.sizeQ == rangeQ - baseQ) return true;
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

  void drop(){
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
        drop();
      }

    }

    for(NormalBlock b: blocks){
      b.cancel();
    }

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

NormalBlocks blocks;
FloorBlock floorBlock;
int[][] field;

int baseQ;
Button reset;
Button drop;

int lastClick;

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

  int[] widths  = {2,2,2,2,2,2,3,3,3,3,3,3,4,4,4,4,6,6,6,6};
  int[] heights = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1};

  blocks= new NormalBlocks(widths,heights);
  floorBlock = new FloorBlock();

  int buttonWidth = 130;
  int buttonHeight = 30;
  reset = new Button(fieldWidth + (menuWidth-buttonWidth)/2, 500,
                     buttonWidth, buttonHeight, "Reset");
  drop = new Button(fieldWidth + (menuWidth-buttonWidth)/2, 550,
                    buttonWidth, buttonHeight, "Drop");

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

  blocks.draw();
  blocks.drawCount();

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
      blocks.init();
      blocks.cancel();
    }
    else{
      blocks.put();
    }

  }
  else{

    if(reset.clicked()){
      blocks.reset();
      return;
    }
    else if(drop.clicked()){
      blocks.dropAll();
      return;
    }
    else{
      blocks.selectNearest();
    }
  }
  lastClick = millis();
}
