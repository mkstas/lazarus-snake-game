program project1;

uses
  gl, glu, glut;

const
  AppWidth = 600;
  AppHeight = 600;
  Step = 32;
  KEY_W = 119;
  KEY_S = 115;
  KEY_A = 97;
  KEY_D = 100;

type
  TSnake = record
    PosX, PosY: Integer;
  end;

  TFood = record
    PosX, PosY: Integer;
    Visible: Boolean;
  end;

  TDirection = (UP, DOWN, LEFT, RIGHT);

var
  ScreenWidth, ScreenHeight: Integer;
  countSnake: Integer;
  dirSnake: TDirection;
  snake: array[0..99] of TSnake;
  food: TFood;

procedure DrawQuad(mode: Integer);
begin
  glBegin(mode);
    glVertex2f(0.0, Step);
    glVertex2f(0.0, 0.0);
    glVertex2f(Step, 0.0);
    glVertex2f(Step, Step);
  glEnd;
end;

procedure CreateFood(value: Integer); cdecl;
var
  x, y: Integer;
begin
  Randomize;

  x := Random(ScreenWidth div Step);
  y := Random(ScreenHeight div Step);

  food.PosX := x * Step;
  food.PosY := y * Step;
  food.Visible := true;
end;

procedure StartGame();
begin
  countSnake := 3;
  dirSnake := UP;

  snake[0].PosX := 10 * Step;
  snake[0].PosY := 2 * Step;
  snake[1].PosX := 10 * Step;
  snake[1].PosY := 1 * Step;
  snake[2].PosX := 10 * Step;
  snake[2].PosY := 0 * Step;
end;

procedure DrawGrid();
var
  i, j: Integer;
begin
  glPushMatrix;
  glColor3f(1.0, 1.0, 1.0);
  glBegin(GL_LINES);

  for i := 0 to (ScreenWidth div Step) do begin
    glVertex2f(0, i * Step);
    glVertex2f(ScreenWidth, i * Step);
  end;

  for j := 0 to (ScreenHeight div Step) do begin
    glVertex2f(j * Step, 0);
    glVertex2f(j * Step, ScreenHeight);
  end;

  glEnd;
  glPopMatrix;
end;

procedure HandleKey(key: Byte; x, y: Integer); cdecl;
begin
  case key of
    KEY_W: dirSnake := UP;
    KEY_S: dirSnake := DOWN;
    KEY_A: dirSnake := LEFT;
    KEY_D: dirSnake := RIGHT;
  end;
end;

function isCollisionFood(): Boolean;
begin
  if ((snake[0].PosX = food.PosX) and (snake[0].PosY = food.PosY)) then
    Result := true
  else
    Result := false;
end;

procedure Update(value: Integer); cdecl;
var
  i: Integer;
begin
  for i := 1 to countSnake - 1 do
    if ((snake[0].PosX = snake[i].PosX) and (snake[0].PosY = snake[i].PosY)) then
      StartGame;

  if (isCollisionFood and food.Visible) then
  begin
    food.Visible := false;
    Inc(countSnake);
    glutTimerFunc(6000, @CreateFood, 0);
  end;

  for i := countSnake - 1 downto 1 do
  begin
    snake[i].PosX := snake[i - 1].PosX;
    snake[i].PosY := snake[i - 1].PosY;
  end;

  case dirSnake of
    UP: snake[0].PosY := snake[0].PosY + step;
    DOWN: snake[0].PosY := snake[0].PosY - step;
    LEFT: snake[0].PosX := snake[0].PosX - step;
    RIGHT: snake[0].PosX := snake[0].PosX + step;
  end;

  if ( snake[0].PosX > ScreenWidth ) then snake[0].PosX := 0;
  if ( snake[0].PosX < 0 ) then snake[1].PosX := ScreenWidth;

  if ( snake[0].PosY > ScreenHeight ) then snake[0].PosY := 0;
  if ( snake[0].PosY < 0 ) then snake[0].PosY := ScreenHeight;

  glutTimerFunc(600, @Update, 0);
end;

procedure InitScene();
begin
  glClearColor(0.3, 0.4, 0.9, 1.0);
  glEnable(GL_DEPTH_TEST);
  StartGame;
end;

procedure RenderScene(); cdecl;
var
  i: Integer;
begin
  glLoadIdentity;
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  DrawGrid;

  if food.Visible then begin
    glPushMatrix;
      glColor3f(1.0, 0.0, 0.0);
      glTranslatef(food.PosX, food.PosY, 0.001);
      DrawQuad(GL_QUADS);
    glPopMatrix;
  end;

  for i := 0 to countSnake - 1 do begin
    glPushMatrix;
      glColor3f(0.0, 1.0, 0.0);
      glTranslatef(snake[i].PosX, snake[i].PosY, 0.001);
      DrawQuad(GL_QUADS);
    glPopMatrix;

    glPushMatrix;
      glColor3f(0.0, 0.0, 0.0);
      glTranslatef(snake[i].PosX, snake[i].PosY, 0.002);
      DrawQuad(GL_LINE_LOOP);
    glPopMatrix;
  end;

  glutSwapBuffers;
  glutPostRedisplay;
end;

procedure ReshapeScene(Width, Height: Integer); cdecl;
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
  glutInitWindowSize(AppWidth, AppHeight);
  ScreenWidth := glutGet(GLUT_SCREEN_WIDTH);
  ScreenHeight := glutGet(GLUT_SCREEN_HEIGHT);
  glutInitWindowPosition((ScreenWidth - AppWidth) div 2,
    (ScreenHeight - AppHeight) div 2);
  glutCreateWindow('Snake game');

  InitScene;

  glutKeyboardUpFunc(@HandleKey);
  glutDisplayFunc(@RenderScene);
  glutReshapeFunc(@ReshapeScene);

  glutTimerFunc(600, @Update, 0);
  glutTimerFunc(600, @CreateFood, 0);

  glutMainLoop;
end.

