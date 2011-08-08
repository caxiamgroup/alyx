component output="false" extends="alyx.models.baseDAO"
{
	public function init(required type)
	{
		variables.type = arguments.type;
		return this;
	}

	public function read()
	{
		if (!StructIsEmpty(arguments) && IsObject(arguments[1]))
		{
			return EntityLoadByExample(arguments[1], false);
		}
		return executeReadHQL(argumentCollection = arguments);
	}

	public function executeReadHQL()
	{
		// Override in table specific DAO
	}

	public function create()
	{
		return EntityNew(variables.type);
	}

	public function save(required bean, forceInsert = false)
	{
		EntitySave(arguments.bean, arguments.forceInsert);
	}

	public function delete(required bean)
	{
		if (StructKeyExists(arguments.bean, "getRecordStatus"))
		{
			softDelete(arguments.bean);
		}
		else
		{
			hardDelete(arguments.bean);
		}
	}

	public function hardDelete(required bean)
	{
		EntityDelete(arguments.bean);
	}

	public function softDelete(required bean)
	{
		bean.setRecordStatus(variables.RECORDSTATUS_DELETED);
		EntitySave(arguments.bean, false);
	}

}