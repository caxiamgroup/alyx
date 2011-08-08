<cfcomponent accessors="true" output="false">

	<cfproperty name="usernameMinLength"/>
	<cfproperty name="usernameMaxLength"/>

	<cfproperty name="passwordMinLength"/>
	<cfproperty name="passwordMaxLength"/>

	<cfproperty name="passwordMask"/>

	<cfproperty name="usernameChars"/>
	<cfproperty name="passwordChars"/>

	<cfproperty name="passwordRegExp"/>
	<cfproperty name="badWords"/>

<cfscript>

	public function init(
		usernameMinLength = 5,
		usernameMaxLength = 50,
		passwordMinLength = 8,
		passwordMaxLength = 64,
		passwordMask      = "****************",
		usernameChars     = "0123456789abcdeghijlmnopqrtvwxyz",
		passwordChars     = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
		passwordRegExp    = application.controller.getPlugin("snippets").getSnippet("pci_password", "regexp"),
		badWords          = application.controller.getPlugin("snippets").getSnippet("pci_password_bad_words", "regexp")
	)
	{
		StructAppend(variables, arguments);
		return this;
	}

	public function hashPassword(required userId, required password)
	{
		return Hash(arguments.userId & arguments.password, "SHA");
	}

	public function generateUsername(
		firstName = "",
		lastName  = "",
		minLength = variables.usernameMinLength,
		maxLength = variables.usernameMaxLength
	)
	{
		var local = StructNew();

		local.base = "";

		if (Len(arguments.firstName))
		{
			arguments.firstName = ReReplace(LCase(arguments.firstName), "[^a-z]", "", "all");
			local.base &= Left(arguments.firstName, 1);
		}
		if (Len(arguments.lastName))
		{
			arguments.lastName = ReReplace(LCase(arguments.lastName), "[^a-z]", "", "all");
			local.base &= Left(arguments.lastName, Max(arguments.maxLength - 6, 1));
		}

		local.numUsernameChars = Len(variables.usernameChars);
		while (Len(local.base) < arguments.minLength)
		{
			local.base &= Mid(variables.usernameChars, RandRange(1, local.numUsernameChars), 1);
		}

		local.username = local.base;

		while (not isUsernameAvailable(username = local.username))
		{
			local.username = local.base & NumberFormat(RandRange(0, 99999), "00000");
		}

		return local.username;
	}

	public function generatePassword(
		minLength = variables.passwordMinLength,
		maxLength = arguments.minLength + 4
	)
	{
		var local = StructNew();

		local.numPasswordChars = Len(variables.passwordChars);

		do
		{
			local.password = "";
			for (local.index = RandRange(arguments.minLength, arguments.maxLength); local.index >= 1; --local.index)
			{
				local.password &= Mid(variables.passwordChars, RandRange(1, local.numPasswordChars), 1);
			}
		}
		while (REFind(variables.passwordRegExp, local.password) == 0 || REFindNoCase(variables.badWords, local.password) neq 0);

		return local.password;
	}

	public function isUsernameAvailable(required username)
	{
		throw(message = "You need to override this function in your application.");
	}

</cfscript>
</cfcomponent>