component output="false" extends="alyx.models.baseService"
{

	public function init()
	{
		return this;
	}

	public function read()
	{
		if (StructIsEmpty(arguments))
		{
			return create();
		}

		local.data = variables.dao.read(argumentCollection = arguments);

		if (local.data.recordCount > 1)
		{
			Throw(type = "MULTIPLE_RETURN", message = "Expected 1 result, received multiple.");
		}

		if (local.data.recordCount == 0)
		{
			return create();
		}

		return queryToBean(local.data);
	}

	public function delete()
	{
		if (IsObject(arguments[1]))
		{
			variables.dao.delete(arguments[1]);
		}
		else
		{
			local.data = variables.dao.read(argumentCollection = arguments);
			if (local.data.recordCount == 1)
			{
				variables.dao.delete(queryToBean(local.data));
			}
			else if (local.data.recordCount > 1)
			{
				Throw(type = "MULTIPLE_RETURN", message = "Expected 1 result, recieved multiple.");
			}
		}
	}

	package function queryToArray(data, queryArguments = StructNew())
	{
		/*
			MAKE SURE YOUR COLDFUSION CLASS PATHS INCLUDE THE FOLLOWING PATH
			alyx/java/lib/
		 */
		local.results = CreateObject("Java", "PagedArray").init();
		local.numRows = arguments.data.recordcount;
		local.columns = ListToArray(arguments.data.columnList);
		local.numColumns = ArrayLen(local.columns);
		local.results.setRecordCount(local.numRows);
		if(StructKeyExists(arguments.queryArguments, "pageIndex") && StructKeyExists(arguments.queryArguments, "pageSize"))
		{
			local.results.setRecordCount(variables.dao.getResultRecordCount());
			local.results.setPageSize(arguments.queryArguments.pageSize);
			local.results.setPageIndex(arguments.queryArguments.pageIndex);
		}

		for (local.rowIndex = 1; local.rowIndex <= local.numRows; ++local.rowIndex)
		{
			local.bean = create();

			for (local.colIndex = 1; local.colIndex <= local.numColumns; ++local.colIndex)
			{
				local.column = local.columns[local.colIndex];
				if (Len(arguments.data[local.column][local.rowIndex]))
				{
					if (StructKeyExists(local.bean, "set" & local.column))
					{
						Evaluate("local.bean.set#local.column#(arguments.data[local.column][local.rowIndex])");
					}
				}
			}

			ArrayAppend(local.results, local.bean);
		}

		return local.results;
	}

	package function queryToBean(data, rowIndex = 1)
	{
		local.columns = ListToArray(arguments.data.columnList);
		local.numColumns = ArrayLen(local.columns);
		local.bean = create();

		for (local.colIndex = 1; local.colIndex <= local.numColumns; ++local.colIndex)
		{
			local.column = local.columns[local.colIndex];
			if (Len(arguments.data[local.column][arguments.rowIndex]))
			{
				if (StructKeyExists(local.bean, "set" & local.column))
				{
					Evaluate("local.bean.set#local.column#(arguments.data[local.column][arguments.rowIndex])");
				}
			}
		}

		return local.bean;
	}

}