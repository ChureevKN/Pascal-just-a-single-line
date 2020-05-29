Program line;
USES wincrt, graph; //WINCRT allows controls in the graphics output window itself

CONST turns_max = 15; // determines line complexness

type direction = (up, right, down, left);
type coord = record
    x, y: word;
    end;
var i, x, y, n: Integer;
x_m, y_m: SmallInt;
edge_x: Integer = 800; // edges: vertical
edge_y: Integer = 700; // and horizontal
x1, y1: Integer; //desired point coords
current: direction;
exc: set of direction; //set of exclusion.
par_driver, par_mode: Integer; par_path: String;
turns_number: Integer; //parameter of how many turns line did
par_reset: Byte; //sets 1 if movement finished with full reset

//function of direction inverting. very useful. returns inverted direction!
FUNCTION inv_dir (given: direction) : direction;

Begin
case given of
    up: inv_dir:= down;
    right: inv_dir:= left;
    down: inv_dir:= up;
    left: inv_dir:= right;
    end;
End;
//----------------------------------------------

//resets the line
PROCEDURE full_reset;

Begin
ClearDevice;
MoveTo (30, 30);
par_reset:=1;
exc:=[up, left];
turns_number := 0; //full reset is just full
End;
//-----------------------

//draw line to proper position. aware of walls and the line itself.
PROCEDURE move (current: direction);

Begin
//draw if not present and not excluded. else turn somewhere else. can't find the way - reset
if (((current in exc) = false) and (GetPixel (x1, y1) <> 15) {and (GetPixel (x1-1, y1-1) <> 15) and (GetPixel (x1-1, y1+1) <> 15) and (GetPixel (x1+1, y1-1) <> 15) and (GetPixel (x1+1, y1+1) <> 15)})
    then begin LineTo (x1, y1); turns_number:=turns_number + 1 end//counts line turns
    else
    begin
    include (exc, current);
    for i:=0 to 3 do //seek for permission
        if (direction(i) in exc) = false
            then
            begin move (direction(i)); exit; end; //work is done here (paint)
    //if not exited, proceeds here
    full_reset;//because line has to intercept itself
    end;
End;
//----------------------------------

//main part begins
Begin
par_driver:= 0; par_mode:= 0; par_path:= '';
InitGraph (par_driver, par_mode, par_path);
ClearDevice;
randomize;
exc:=[up, left];
//check prescribed edges
x_m:=GetMaxX; y_m:=GetMaxY;
if edge_x > x_m then begin edge_x := x_m - 35; writeLn('    ### Vertical edge corrected to the edge of the screen ###'); end;
if edge_y > y_m then begin edge_y := y_m - 35; writeLn('    ### Horizontal edge corrected to the edge of the screen ###'); end;

SetLineStyle (Solidln, 0, ThickWidth); MoveTo (30,30);

//endless cycle 1 - controls line complexness
while true do
    begin
    //endless cycle 2 - paints line
    while true do
        begin
        par_reset:=0; //parameter of whether movement finished with reset or not
        repeat current:=direction (random(4))
        until (current in exc) = false;//choose new move

        case current of
        up: begin x1:=GetX; y1:=GetY-30; end;
        right: begin x1:=GetX+30; y1:=GetY; end;
        down: begin x1:=GetX; y1:=GetY+30; end;
        left: begin x1:=GetX-30; y1:=GetY; end;
            end; //determine new coords

        move (current); exc:=[];//here it is

        // check for an end. otherwise add exclusion for next move (if reseted - do nothing)
        if (GetX > edge_x) or (GetY > edge_y) then break //end of line
            else
            begin
            if par_reset = 0 then include (exc, inv_dir(current))
                else par_reset:=0;
            end;

        //check for deadend
        if GetX=30 then include (exc, left); if GetY=30 then include (exc, up);

        end; //cycle 2 end

    if turns_number < turns_max
        then full_reset
        else break; //line's complexity determined by constant
    end; //cycle 1 end

readkey;
CloseGraph;
End.