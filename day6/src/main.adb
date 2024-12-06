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

   type Position_Record is record
      X : Integer;
      Y : Integer;
   end record;

   type Direction_Record is record
      dx : Integer;
      dy : Integer;
   end record;

   type State_Record is record
      pos : Position_Record;
      dir : Direction_Record;
   end record;

   Initial_State : State_Record;

   Directions : array (Character) of Direction_Record :=
     ('^'    => (dx => 0, dy => -1),
      'v'    => (dx => 0, dy => 1),
      '<'    => (dx => -1, dy => 0),
      '>'    => (dx => 1, dy => 0),
      others => (dx => 0, dy => 0));
   Direction  : Direction_Record := (dx => 0, dy => 0);

   procedure CopyMatrix (Input : Matrix_Access; Output : out Matrix_Access) is
   begin
      Output := new Matrix (Input'Range(1), Input'Range(2));
      for I in Input'Range(1) loop
         for J in Input'Range(2) loop
            Output (I, J) := Input (I, J);
         end loop;
      end loop;
   end CopyMatrix;

   procedure TurnRight (State : in out State_Record) is
   begin
      if State.dir.dx = 0 and State.dir.dy = -1 then
         State.dir.dx := 1;
         State.dir.dy := 0;
      elsif State.dir.dx = 1 and State.dir.dy = 0 then
         State.dir.dx := 0;
         State.dir.dy := 1;
      elsif State.dir.dx = 0 and State.dir.dy = 1 then
         State.dir.dx := -1;
         State.dir.dy := 0;
      elsif State.dir.dx = -1 and State.dir.dy = 0 then
         State.dir.dx := 0;
         State.dir.dy := -1;
      end if;
   end TurnRight;

   function NextState (Current : State_Record) return State_Record is
      Result : State_Record;
   begin
      Result := Current;
      Result.pos.X := Result.pos.X + Result.dir.dx;
      Result.pos.Y := Result.pos.Y + Result.dir.dy;
      return Result;
   end NextState;

   function IsStateValid (State : State_Record) return Boolean is
   begin
      return State.pos.X in 1 .. Width and State.pos.Y in 1 .. Height;
   end IsStateValid;

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
               Direction := Directions (C);
               Initial_State.pos.X := I;
               Initial_State.pos.Y := Height;
               Initial_State.dir.dx := Direction.dx;
               Initial_State.dir.dy := Direction.dy;
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

   function FirstPart
     (Matrix : Matrix_Access; State : State_Record) return Integer
   is
      Current : State_Record := State;
      Next    : State_Record;

      Tmp : Matrix_Access := Matrix;
      Sum : Natural := 0;
   begin
      Sum := Sum + 1;
      Tmp (Current.pos.Y, Current.pos.X) := 'X';

      loop
         Next := NextState (Current);
         if not (isStateValid (Next)) then
            exit;
         end if;

         if Matrix (Next.pos.Y, Next.pos.X) = '#' then
            TurnRight (Current);
         else
            Current := NextState (Current);
            if Tmp (Current.pos.Y, Current.pos.X) = '.' then
               Sum := Sum + 1;
               Tmp (Current.pos.Y, Current.pos.X) := 'X';
            end if;
         end if;
      end loop;

      return Sum;
   end FirstPart;

   function Hash_State (Key : State_Record) return Ada.Containers.Hash_Type is
      Key_String : String :=
        Integer'Image (Key.pos.X)
        & Integer'Image (Key.pos.Y)
        & Integer'Image (Key.dir.dx)
        & Integer'Image (Key.dir.dy);
   begin
      return Ada.Strings.Hash (Key_String);
   end Hash_State;

   function State_Equal (First, Second : State_Record) return Boolean is
   begin
      return
        First.pos.X = Second.pos.X
        and First.pos.y = Second.pos.y
        and First.dir.dx = Second.dir.dx
        and First.dir.dy = Second.dir.dy;
   end State_Equal;

   package State_Set is new
     Ada.Containers.Hashed_Sets
       (Element_Type        => State_Record,
        Hash                => Hash_State,
        Equivalent_Elements => State_Equal);

   -- Surely there is a faster way to do this
   function SecondPart
     (Matrix : Matrix_Access; State : State_Record) return Integer
   is
      Current : State_Record := State;
      Next    : State_Record;
      Sum     : Integer := 0;

      function IsLoop return Boolean is
         Current : State_Record := State;
         Next    : State_Record;
         Path    : State_Set.Set;
      begin
         Path.Include (Current);

         loop
            Next := NextState (Current);
            if not (IsStateValid (Next)) then
               return False;
            end if;

            if Matrix (Next.pos.Y, Next.pos.X) = '#' then
               TurnRight (Current);
            else
               Current := Next;
            end if;

            if Path.Contains (Current) then
               return True;
            end if;

            Path.Include (Current);
         end loop;
         -- Should never reach this point
         return False;
      end IsLoop;
   begin
      Matrix (Current.pos.Y, Current.pos.X) := 'X';

      loop
         Next := NextState (Current);
         if not (IsStateValid (Next)) then
            exit;
         end if;

         if Matrix (Next.pos.Y, Next.pos.X) = '#' then
            TurnRight (Current);
         else
            Current := Next;

            if Matrix (Current.pos.Y, Current.pos.X) = '.' then
               Matrix (Current.pos.Y, Current.pos.X) := 'X';
            end if;
         end if;
      end loop;

      for I in 1 .. Height loop
         for J in 1 .. Width loop
            if not (I = Initial_State.pos.Y and J = Initial_State.pos.X)
              and Matrix (I, J) = 'X'
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

   CopyMatrix (Problem, FirstPartMatrix);
   Put_Line
     ("First part:"
      & Integer'Image (FirstPart (FirstPartMatrix, Initial_State)));

   CopyMatrix (Problem, SecondPartMatrix);
   Put_Line
     ("Second part:"
      & Integer'Image (SecondPart (SecondPartMatrix, Initial_State)));
end Main;
