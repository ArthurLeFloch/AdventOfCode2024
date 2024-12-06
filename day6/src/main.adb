with Ada.Text_IO; use Ada.Text_IO;

with Ada.Containers.Hashed_Sets;
with Ada.Strings.Hash;
with Ada.Strings.Unbounded;
use Ada.Containers;

procedure Main is

   package UStr renames Ada.Strings.Unbounded;

   type Matrix is array (Positive range <>, Positive range <>) of Character;
   type Matrix_Access is access Matrix;

   Problem : Matrix_Access;
   Width   : Natural := 0;
   Height  : Natural := 0;

   Initial_X : Natural := 0;
   Initial_Y : Natural := 0;
   Direction : Character := '^';

   procedure CopyMatrix (Input : Matrix_Access; Output : out Matrix_Access) is
   begin
      Output := new Matrix (Input'Range(1), Input'Range(2));
      for I in Input'Range(1) loop
         for J in Input'Range(2) loop
            Output (I, J) := Input (I, J);
         end loop;
      end loop;
   end CopyMatrix;

   procedure SetDirection
     (D : Character; dx : in out Integer; dy : in out Integer) is
   begin
      if D = '^' then
         dx := 0;
         dy := -1;
      elsif D = 'v' then
         dx := 0;
         dy := 1;
      elsif D = '<' then
         dx := -1;
         dy := 0;
      elsif D = '>' then
         dx := 1;
         dy := 0;
      end if;
   end SetDirection;

   procedure TurnRight (dx : in out Integer; dy : in out Integer) is
   begin
      if dx = 0 and dy = -1 then
         dx := 1;
         dy := 0;
      elsif dx = 1 and dy = 0 then
         dx := 0;
         dy := 1;
      elsif dx = 0 and dy = 1 then
         dx := -1;
         dy := 0;
      elsif dx = -1 and dy = 0 then
         dx := 0;
         dy := -1;
      end if;
   end TurnRight;

   procedure ParseInput (File_Name : String) is
      File         : File_Type;
      Current_Line : UStr.Unbounded_String;
      C            : Character;

      procedure AddLine (Line : UStr.Unbounded_String) is
      begin
         for I in 1 .. Width loop
            C := UStr.Element (Line, I);
            Problem (Height, I) := C;
            if C = '^' or C = 'v' or C = '<' or C = '>' then
               Initial_X := I;
               Initial_Y := Height;
            end if;
         end loop;
      end AddLine;

   begin
      Open (File, In_File, File_Name);

      Current_Line := UStr.To_Unbounded_String (Get_Line (File));
      Width := UStr.Length (Current_Line);
      Height := 1;

      Problem := new Matrix (1 .. Width, 1 .. Width);

      AddLine (Current_Line);

      while not End_Of_File (File) loop
         Height := Height + 1;
         Current_Line := UStr.To_Unbounded_String (Get_Line (File));
         AddLine (Current_Line);
      end loop;
      Close (File);
   end ParseInput;

   function FirstPart (Problem : Matrix_Access) return Integer is
      dx : Integer := 0;
      dy : Integer := 0;

      X : Integer := Initial_X;
      Y : Integer := Initial_Y;
      D : Character := Direction;

      Tmp : Matrix_Access := Problem;
      Sum : Natural := 0;
   begin
      SetDirection (D, dx, dy);

      Sum := Sum + 1;
      Tmp (Y, X) := 'X';

      loop
         if X + dx > Width or X + dx < 1 or Y + dy > Height or Y + dy < 1 then
            exit;
         end if;

         if Problem (Y + dy, X + dx) = '#' then
            TurnRight (dx, dy);
         else
            X := X + dx;
            Y := Y + dy;
            if Tmp (Y, X) = '.' then
               Sum := Sum + 1;
               Tmp (Y, X) := 'X';
            end if;
         end if;
      end loop;

      return Sum;
   end FirstPart;

   type Quad_Int is record
      x, y, dx, dy : Integer;
   end record;

   function Hash_Quad_Int (Key : Quad_Int) return Ada.Containers.Hash_Type is
      Key_String : String := Integer'Image(Key.x) & Integer'Image(Key.y) & Integer'Image(Key.dx) & Integer'Image(Key.dy);
   begin
      return Ada.Strings.Hash (Key_String);
   end Hash_Quad_Int;

   function Quad_Int_Equal (First, Second : Quad_Int) return Boolean is
   begin
      return
        First.x = Second.x
        and First.y = Second.y
        and First.dx = Second.dx
        and First.dy = Second.dy;
   end Quad_Int_Equal;

   package Quad_Int_Set is new
     Ada.Containers.Hashed_Sets
       (Element_Type    => Quad_Int,
        Hash            => Hash_Quad_Int,
        Equivalent_Elements => Quad_Int_Equal);

   -- Surely there is a faster way to do this
   function SecondPart (Matrix : Matrix_Access) return Integer is
      dx : Integer := 0;
      dy : Integer := 0;

      X   : Integer := Initial_X;
      Y   : Integer := Initial_Y;
      D   : Character := Direction;
      Sum : Integer := 0;

      function IsLoop return Boolean is
         X    : Integer := Initial_X;
         Y    : Integer := Initial_Y;
         dx   : Integer := 0;
         dy   : Integer := 0;
         Path : Quad_Int_Set.Set;
      begin
         SetDirection (D, dx, dy);

         Path.Include (Quad_Int'(X, Y, dx, dy));

         loop
            if X + dx > Width or X + dx < 1 or Y + dy > Height or Y + dy < 1
            then
               return False;
            end if;

            if Matrix (Y + dy, X + dx) = '#' then
               TurnRight (dx, dy);
            else
               X := X + dx;
               Y := Y + dy;
            end if;

            if Path.Contains (Quad_Int'(X, Y, dx, dy)) then
               return True;
            end if;

            Path.Include (Quad_Int'(X, Y, dx, dy));
         end loop;
         -- Should never reach this point
         return False;
      end IsLoop;

   begin
      SetDirection (D, dx, dy);

      Matrix (Y, X) := 'X';

      loop
         if X + dx > Width or X + dx < 1 or Y + dy > Height or Y + dy < 1 then
            exit;
         end if;
         if Problem (Y + dy, X + dx) = '#' then
            TurnRight (dx, dy);
         else
            X := X + dx;
            Y := Y + dy;

            if Matrix (Y, X) = '.' then
               Matrix (Y, X) := 'X';
            end if;
         end if;
      end loop;

      for I in 1 .. Height loop
         for J in 1 .. Width loop
            if not (I = Initial_Y and J = Initial_X) and Matrix (I, J) = 'X'
            then
               Matrix (I, J) := '#';
               if IsLoop then
                  Sum := Sum + 1;
               end if;
               Matrix (I, J) := 'X';
            end if;
         end loop;
      end loop;

      return Sum;
   end SecondPart;

   FirstPartMatrix  : Matrix_Access;
   SecondPartMatrix : Matrix_Access;
begin
   ParseInput ("input.txt");

   Put_Line ("Width:" & Integer'Image (Width));
   Put_Line ("Height:" & Integer'Image (Height));
   Put_Line
     ("Initial position:"
      & Integer'Image (Initial_X)
      & ","
      & Integer'Image (Initial_Y));
   Put_Line ("Initial direction: " & Direction);

   CopyMatrix (Problem, FirstPartMatrix);
   Put_Line ("First part:" & Integer'Image (FirstPart (FirstPartMatrix)));

   CopyMatrix (Problem, SecondPartMatrix);
   Put_Line ("Second part:" & Integer'Image (SecondPart (SecondPartMatrix)));
end Main;
