<cfcomponent name="baseService" output="no" hint="Abstract base class for model services">
<cfscript>

	public function getPlugin(name)
	{
		return application.controller.getPlugin(arguments.name);
	}

	public function getService(name)
	{
		return application.controller.getService(arguments.name);
	}

</cfscript>
</cfcomponent>