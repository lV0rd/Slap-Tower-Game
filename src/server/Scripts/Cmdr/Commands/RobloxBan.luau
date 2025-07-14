return {
	Name = "Ban";
	Aliases = {"rban", "ban", "b", "rb"};
	Description = "Ban player";
	Group = "Admin";
	Args = {
        {
            Type = "player";
            Name = "Player";
            Description = "Selected player",
            Optional = false
        },
		{
            Type = "number";
            Name = "Duration";
            Description = "Duration of ban (-1 for perm)",
            Optional = false
        },
		{
            Type = "string";
            Name = "Reason";
            Description = "Reason for ban",
            Optional = true
        },
	};
}