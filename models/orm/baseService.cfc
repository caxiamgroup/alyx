component output="false" extends="alyx.models.baseService"
{

	public function init()
	{
		return this;
	}

	public function create()
	{
		return variables.dao.create();
	}

	public function read()
	{
		if (StructIsEmpty(arguments))
		{
			return create();
		}

		local.results = variables.dao.read(argumentCollection = arguments);

		if (ArrayLen(local.results) > 1)
		{
			Throw(type = "MULTIPLE_RETURN", message = "Expected 1 result, received multiple.");
		}

		if (ArrayIsEmpty(local.results))
		{
			return create();
		}

		return local.results[1];
	}

	public function delete(required bean)
	{
		variables.dao.delete(bean = arguments.bean);
	}

	public function save(required bean)
	{
		variables.dao.save(argumentCollection = arguments);
	}

}