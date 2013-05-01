with Railval.Trace;

package body Railval.Parser is
   use Railval;

   --  Defines a previously undefined track and allocates it.
   procedure Define (Object : in out Railway_Networks;
                     ID     : in Identifications) with
     Precondition  => not Object.Is_Defined (ID),
   Postcondition => Object.Map (ID) = New_Rail;

   -------------
   --  Check  --
   -------------

   function Check (Item : in Rails) return Boolean is
   begin
      return Item.Defined and Item.Kind = Invalid;
   end Check;

   -------------
   --  Check  --
   -------------

   function Check (Rail : in Frozen_Rails) return Boolean is
      use Ada.Containers;
      Context : constant String := Package_Name & ".Validate (Frozen_Rails)";
   begin
      return Rail.Kind /= Invalid and Rail.Links.Length > 1;
         return False;
   end Check;

   --------------
   --  Define  --
   --------------

   procedure Define (Object : in out Railway_Networks;
                     ID     : in     Identifications) is
      Context : constant String := Package_Name & ".Define";
   begin
      Trace.Debug (Context => Context,
                   Message =>
                     "Defining new non-station link " & Character (ID));

      Object.Map (ID) := New_Rail;
   end Define;

   -----------------------
   --  Define_Endpoint  --
   -----------------------

   procedure Define_Endpoint (Object         : in out Railway_Networks;
                              Identification : in Identifications) is
      Context : constant String := Package_Name & ".Define_Endpoint";

      Rail    : Rails renames Object.Map (Identification);
   begin

      if not Rail.Defined then
         Define (Object, Identification);
      end if;

      Object.Map (Identification).Links.Append
        (Tokenizer.End_Point_Identification);

      Trace.Debug (Context => Context,
                   Message => "Defining endpoint " &
                     Character (Identification));
   end Define_Endpoint;

   --------------------
   --  Dump_Network  --
   --------------------

   procedure Dump_Network (Object : in out Railway_Networks) is
      Context : constant String := Package_Name & ".Dump_Network";
   begin
      for I in Identifications'Range loop
         if Object.Map (I).Defined then
            Trace.Debug (Context => Context,
                         Message => Image (I) & " " &
                           Image (Object.Map (I)));
         end if;
      end loop;
   end Dump_Network;

   -------------
   --  Image  --
   -------------

   function Image (Item : Connection_Storage.Vector) return String is
      Buffer   : String (1 .. 16);
      Position : Natural := Buffer'First;
   begin
      for Element of Item loop
         Buffer (Position) := Character (Element);
         Buffer (Position + 1) := ' ';
         Position          := Position + 2;
      end loop;

      return Buffer (Buffer'First .. Position-1);
   end Image;

   -------------
   --  Image  --
   -------------

   function Image (Item : in Rails) return String is
      use Station_Names;
   begin
      case Item.Kind is
         when Invalid =>
            return Item.Kind'Img;
         when Link =>
            return Item.Kind'Img & " " & Image (Item.Links);
         when Station =>
            return Item.Kind'Img & " " &
              To_String (Item.Name) & " " & Image (Item.Links);
      end case;
   end Image;

   ------------------
   --  Is_Defined  --
   ------------------

   function Is_Defined
     (Object         : in out Railway_Networks;
      Identification : in     Identifications) return Boolean
   is
   begin
      return Object.Map (Identification).Defined;
   end Is_Defined;

   ---------------
   --  Is_Link  --
   ---------------

   function Is_Link
     (Object         : in out Railway_Networks;
      Identification : in     Identifications) return Boolean
   is
   begin
      return Object.Map (Identification).Kind = Link;
   end Is_Link;

   ------------
   --  Link  --
   ------------

   procedure Link
     (Object          : in out Railway_Networks;
      Identification1 : in     Identifications;
      Identification2 : in     Identifications) is
      Context : constant String := Package_Name & ".Link";

      Rail1   : Rails renames Object.Map (Identification1);
      Rail2   : Rails renames Object.Map (Identification2);

   begin
      Trace.Debug (Context => Context,
                   Message =>
                     "Linking " & Character (Identification1) & " and " &
                     Character (Identification2));

      if not Rail1.Defined then
         Define (Object, Identification1);
      end if;

      if not Rail2.Defined then
         Define (Object, Identification2);
         Trace.Debug (Context => Context,
                      Message =>
                        "Defining " & Character (Identification2));
      end if;

      Object.Map (Identification1).Links.Append (Identification2);
      Object.Map (Identification2).Links.Append (Identification1);

   end Link;

   ----------------------
   --  Define_Station  --
   ----------------------

   procedure Define_Station (Object         : in out Railway_Networks;
                             Name           : in String;
                             Identification : in Identifications) is
      use Station_Names;

      Context : constant String := Package_Name & ".Define_Station";

   begin
      if Object.Map (Identification).Defined then
         Trace.Debug (Context => Context,
                      Message => Character (Identification) & " Defined");
      else
         Trace.Debug (Context => Context,
                      Message => Character (Identification) & " Not defined");
         Object.Map (Identification) :=
           (Defined        => True,
            Kind           => Station,
            Name           => To_Bounded_String (Name),
            Links          => Connection_Storage.Empty_Vector);
      end if;
   end Define_Station;

   ----------------
   --  Validate  --
   ----------------

   procedure Validate (Object : in out Railway_Networks) is
   begin
      for Item of Object.Map loop
         if Item.Defined then
            declare
               Freeze : Frozen_Rails := Frozen_Rails (Item);
            begin
               null;
            end;
         end if;
      end loop;
   end Validate;

end Railval.Parser;
