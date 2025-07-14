program project1;

uses
  SysUtils, gl, glu, glut;

const
  APP_WIDTH = 1024;
  APP_HEIGHT = 640;
  TILE_SIZE = 32;

type
  TSnake = record
    PosX, PosY: Integer;
  end;

  TWall = record
    PosX, PosY: Integer;
  end;

  TFood = record
    PosX, PosY: Integer;
    Visible: Boolean;
  end;

  TDirection = (UP, DOWN, LEFT, RIGHT);

var
  ScreenWidth, ScreenHeight: Integer;
  snake: array[0..10000] of TSnake;
  snakeSize: Integer;
  snakeDir: TDirection;
  walls: array[0..174] of TWall;
  food: TFood;

procedure HandleSpecialKey(key, x, y: Integer); cdecl;
begin
  case snakeDir of
    UP, DOWN: case key of
      GLUT_KEY_LEFT: snakeDir := LEFT;
      GLUT_KEY_RIGHT: snakeDir := RIGHT;
    end;

    LEFT, RIGHT: case key of
      GLUT_KEY_UP: snakeDir := UP;
      GLUT_KEY_DOWN: snakeDir := DOWN;
    end;
  end;
end;

function isCollisionFood: Boolean;
begin
  if ((snake[0].PosX = food.PosX) and (snake[0].PosY = food.PosY)) then
    Result := true
  else
    Result := false;
end;

procedure CreateFood(value: Integer); cdecl;
var
  x, y, i: Integer;
  flag: Boolean;
begin
  Randomize;

  flag := true;

  repeat
    x := Random(ScreenWidth div TILE_SIZE - 2) + 1;
    y := Random(ScreenHeight div TILE_SIZE - 2) + 1;

    for i := 0 to snakeSize - 1 do
      if (snake[i].PosX = x * TILE_SIZE) and (snake[i].PosY = y * TILE_SIZE) then
      begin
        flag := false;
        Break;
      end
      else
        flag := true;

    if not flag then
    begin
      for i := 0 to Length(walls) - 1 do
      if (walls[i].PosX = x * TILE_SIZE) and (walls[i].PosY = y * TILE_SIZE) then
      begin
        flag := false;
        Break;
      end
      else
        flag := true;
    end;
  until flag;

  food.PosX := x * TILE_SIZE;
  food.PosY := y * TILE_SIZE;
  food.Visible := true;
end;

procedure DrawQuad(mode: Integer);
begin
  glBegin(mode);
    glVertex2f(0.0, TILE_SIZE);
    glVertex2f(0.0, 0.0);
    glVertex2f(TILE_SIZE, 0.0);
    glVertex2f(TILE_SIZE, TILE_SIZE);
  glEnd;
end;

procedure DrawText(x, y: GLfloat; const text: string);
var
  i: Integer;
begin
  glRasterPos2f(x, y);
  for i := 1 to Length(text) do
    glutBitmapCharacter(GLUT_BITMAP_HELVETICA_18, Ord(text[i]));
end;

procedure DrawScore;
var
  i: Integer;
  score: String;
begin
  glDisable(GL_DEPTH_TEST);

  score := '';
  for i := 1 to 8 - Length(IntToStr((snakeSize - 3) * 100)) do
  begin
    score += '0';
  end;

  score += IntToStr((snakeSize - 3) * 100);

  glColor3f(1.0, 1.0, 1.0);
  DrawText(32 * 15, 617, score);

  glEnable(GL_DEPTH_TEST);
end;

procedure DrawWalls;
var
  i: Integer;
begin
  for i := 0 to 31 do
  begin
    walls[i].PosX := i * 32;
    walls[i].PosY := 0;

    walls[i + 32].PosX := i * (ScreenWidth div TILE_SIZE);
    walls[i + 32].PosY := 19 * TILE_SIZE;
  end;

  for i := 64 to 83 do
  begin
    walls[i].PosX := 0;
    walls[i].PosY := (i - 64) * TILE_SIZE;

    walls[i + 20].PosX := 31 * TILE_SIZE;
    walls[i + 20].PosY := (i - 64) * TILE_SIZE;
  end;

  for i := 104 to 112 do
  begin
    walls[i].PosX := (i - 100) * TILE_SIZE;
    walls[i].PosY := 4 * TILE_SIZE;

    walls[i + 9].PosX := (i - 85) * TILE_SIZE;
    walls[i + 9].PosY := 4 * TILE_SIZE;

    walls[i + 18].PosX := (i - 100) * TILE_SIZE;
    walls[i + 18].PosY := 15 * TILE_SIZE;

    walls[i + 27].PosX := (i - 85) * TILE_SIZE;
    walls[i + 27].PosY := 15 * TILE_SIZE;
  end;

  for i := 140 to 143 do
  begin
    walls[i].PosX := 4 * TILE_SIZE;
    walls[i].PosY := (i - 136) * TILE_SIZE;

    walls[i + 4].PosX := 4 * TILE_SIZE;
    walls[i + 4].PosY := (i - 128) * TILE_SIZE;

    walls[i + 8].PosX := 27 * TILE_SIZE;
    walls[i + 8].PosY := (i - 136) * TILE_SIZE;

    walls[i + 12].PosX := 27 * TILE_SIZE;
    walls[i + 12].PosY := (i - 128) * TILE_SIZE;
  end;

  for i := 155 to 159 do
  begin
    walls[i].PosX := (i - 146) * TILE_SIZE;
    walls[i].PosY := 8 * TILE_SIZE;

    walls[i + 5].PosX := (i - 146) * TILE_SIZE;
    walls[i + 5].PosY := 11 * TILE_SIZE;

    walls[i + 10].PosX := (i - 137) * TILE_SIZE;
    walls[i + 10].PosY := 8 * TILE_SIZE;

    walls[i + 15].PosX := (i - 137) * TILE_SIZE;
    walls[i + 15].PosY := 11 * TILE_SIZE;
  end;

  for i := 0 to Length(walls) - 1 do
  begin
    glPushMatrix;
      glColor3f(0.05, 0.05, 0.05);
      glTranslatef(walls[i].PosX, walls[i].PosY, 0.3);
      DrawQuad(GL_QUADS);
    glPopMatrix;
  end;
end;

procedure StartGame;
begin
  snakeSize := 3;
  snakeDir := RIGHT;

  snake[0].PosX := 8 * TILE_SIZE;
  snake[0].PosY := 2 * TILE_SIZE;
  snake[1].PosX := 7 * TILE_SIZE;
  snake[1].PosY := 2 * TILE_SIZE;
  snake[2].PosX := 6 * TILE_SIZE;
  snake[2].PosY := 2 * TILE_SIZE;
end;

procedure UpdateGame(value: Integer); cdecl;
var
  i: Integer;
begin
  for i := 1 to snakeSize - 1 do
    if ((snake[0].PosX = snake[i].PosX) and (snake[0].PosY = snake[i].PosY)) then
      StartGame;

  for i := 0 to Length(walls) - 1 do
    if ((snake[0].PosX = walls[i].PosX) and (snake[0].PosY = walls[i].PosY)) then
      StartGame;

  if (isCollisionFood and food.Visible) then
  begin
    food.Visible := false;
    Inc(snakeSize);
    glutTimerFunc(100, @CreateFood, 0);
    DrawScore;
  end;

  for i := snakeSize - 1 downto 1 do
  begin
    snake[i].PosX := snake[i - 1].PosX;
    snake[i].PosY := snake[i - 1].PosY;
  end;

  case snakeDir of
    UP: snake[0].PosY := snake[0].PosY + TILE_SIZE;
    DOWN: snake[0].PosY := snake[0].PosY - TILE_SIZE;
    LEFT: snake[0].PosX := snake[0].PosX - TILE_SIZE;
    RIGHT: snake[0].PosX := snake[0].PosX + TILE_SIZE;
  end;

  glutTimerFunc(200, @UpdateGame, 0);
end;

procedure InitDisplay;
begin
  glClearColor(0.25, 0.25, 0.25, 1.0);
  glEnable(GL_DEPTH_TEST);

  StartGame;
end;

procedure RenderDisplay(); cdecl;
var
  i: Integer;
begin
  glLoadIdentity;
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  DrawWalls;

  if food.Visible then begin
    glPushMatrix;
      glColor3f(1.0, 0.2, 0.2);
      glTranslatef(food.PosX, food.PosY, 0.1);
      DrawQuad(GL_QUADS);
    glPopMatrix;
  end;

  for i := 0 to snakeSize - 1 do begin
    glPushMatrix;
      glColor3f(0.2, 1.0, 0.2);
      glTranslatef(snake[i].PosX, snake[i].PosY, 0.2);
      DrawQuad(GL_QUADS);
    glPopMatrix;
  end;

  DrawScore;

  glutSwapBuffers;
  glutPostRedisplay;
end;

procedure ReshapeDisplay(Width, Height: Integer); cdecl;
begin
  ScreenWidth := Width;
  ScreenHeight := Height;

  glViewport(0, 0, ScreenWidth, ScreenHeight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;

  gluOrtho2D(0, ScreenWidth, 0, ScreenHeight);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
end;

begin
  glutInit(@argc, @argv);
  glutInitDisplayMode(GLUT_RGBA or GLUT_DOUBLE or GLUT_DEPTH);
  glutInitWindowSize(APP_WIDTH, APP_HEIGHT);

  ScreenWidth := glutGet(GLUT_SCREEN_WIDTH);
  ScreenHeight := glutGet(GLUT_SCREEN_HEIGHT);

  glutInitWindowPosition((ScreenWidth - APP_WIDTH) div 2,
    (ScreenHeight - APP_HEIGHT) div 2);
  glutCreateWindow('Snake game');

  InitDisplay;

  glutDisplayFunc(@RenderDisplay);
  glutReshapeFunc(@ReshapeDisplay);
  glutSpecialFunc(@HandleSpecialKey);

  glutTimerFunc(1000, @UpdateGame, 0);
  glutTimerFunc(100, @CreateFood, 0);

  glutMainLoop;
end.
