<cfcomponent>

	<cffunction name="safeDollarFormat" output="no">
		<cfargument name="value" required="yes"/>
		<cfargument name="defaultValue" default="#arguments.value#"/>

		<cfif IsNumeric(arguments.value)>
			<cfreturn DollarFormat(arguments.value)/>
		</cfif>
		<cfreturn arguments.defaultValue/>
	</cffunction>

	<cffunction name="safeDecimalFormat" output="no">
		<cfargument name="value" required="yes"/>
		<cfargument name="defaultValue" default="#arguments.value#"/>

		<cfif IsNumeric(arguments.value)>
			<cfreturn NumberFormat(arguments.value, ",0.00")/>
		</cfif>
		<cfreturn arguments.defaultValue/>
	</cffunction>

	<cffunction name="safeNumberFormat" output="no">
		<cfargument name="value" required="yes"/>
		<cfargument name="defaultValue" default="#arguments.value#"/>

		<cfif IsNumeric(arguments.value)>
			<cfreturn NumberFormat(arguments.value, ",0")/>
		</cfif>
		<cfreturn arguments.defaultValue/>
	</cffunction>

	<cffunction name="safeDateFormat" output="no">
		<cfargument name="value" required="yes"/>
		<cfargument name="format" default="mm/dd/yyyy"/>
		<cfargument name="defaultValue" default="#arguments.value#"/>

		<cfif IsDate(arguments.value)>
			<cfreturn DateFormat(arguments.value, arguments.format)/>
		</cfif>
		<cfreturn arguments.defaultValue/>
	</cffunction>

	<cffunction name="extractNumber" output="no">
		<cfargument name="value"   required="yes"/>
		<cfargument name="default" default=""/>

		<cfset var local = StructNew()/>

		<cfset local.results = arguments.default/>
		<cfset local.value = ReReplace(arguments.value, "[^0-9.-]", "", "all")/>
		<cfif Len(local.value) and IsNumeric(local.value)>
			<cfset local.results = local.value/>
		</cfif>

		<cfreturn local.results/>
	</cffunction>

	<cffunction name="extractDecimal" output="no">
		<cfargument name="value"   required="yes"/>
		<cfargument name="default" default=""/>

		<cfset var local = StructNew()/>

		<cfset local.results = arguments.default/>
		<cfset local.value = ReReplace(arguments.value, "[^0-9.-]", "", "all")/>
		<cfif Len(local.value) and IsNumeric(local.value)>
			<cfset local.results = NumberFormat(local.value, "0.00")/>
		</cfif>

		<cfreturn local.results/>
	</cffunction>

	<cfscript>
	function tableFormat(value)
	{
		value = Trim(value);
		if (not Len(value))
		{
			value = "&nbsp;";
		}
		return value;
	}

	function phoneFormat(value)
	{
		var numArgs = ArrayLen(arguments);
		var tmpValue = "";
		var newValue = "";
		var maskPos = 1;
		var valuePos = 1;
		var c = "";
		var maskLen = "";
		var valueLen = "";
		var mask = "xxx-xxx-xxxx";

		if (numArgs gte 2 and Len(Trim(arguments[2])))
		{
			mask = Trim(arguments[2]);
		}

		tmpValue = ReReplace(value, "[^A-Za-z0-9]", "", "all");

		if (Len(tmpValue) lte 11 and Len(tmpValue) gte 7)
		{
			maskLen = Len(mask);
			mask = Reverse(mask);
			tmpValue = Reverse(tmpValue);
			valueLen = Len(tmpValue);

			for (maskPos = 1; maskPos lte maskLen and valuePos lte valueLen; ++maskPos)
			{
				c = Mid(mask, maskPos, 1);
				if (c eq "x")
				{
					newValue = newValue & Mid(tmpValue, valuePos, 1);
					valuePos = valuePos + 1;
				}
				else
				{
					newValue = newValue & c;
				}
			}
			// Special case for closing grouping symbol
			if (maskPos eq maskLen)
			{
				newValue = newValue & Mid(mask, maskPos, 1);
			}
			newValue = Reverse(newValue);
		}
		else
		{
			newValue = value;
		}

		return Trim(newValue);
	}

	function emailFormat(value)
	{
		value = Trim(value);
		if (Len(value) and IsValid("email", value))
		{
			value = "<a href=""mailto:" & value & """>" & value & "</a>";
		}
		return value;
	}

	function formatDay(value)
	{
		var suffix = "th";
		switch (value)
		{
			case 1:
			case 21:
			case 31:
				suffix = "st";
				break;
			case 2:
			case 22:
				suffix = "nd";
				break;
			case 3:
			case 23:
				suffix = "rd";
				break;
		}
		return value & suffix;
	}
	</cfscript>

	<cffunction name="addressFormat" output="no">
		<cfargument name="addressLine1" default=""/>
		<cfargument name="addressLine2" default=""/>
		<cfargument name="city" default=""/>
		<cfargument name="state" default=""/>
		<cfargument name="zipCode" default=""/>

		<cfset var address = ""/>

		<cfif Len(arguments.addressLine1)>
			<cfif Len(address)>
				<cfset address &= "<br />"/>
			</cfif>
			<cfset address &= arguments.addressLine1/>
		</cfif>

		<cfif Len(arguments.addressLine2)>
			<cfif Len(address)>
				<cfset address &= "<br />"/>
			</cfif>
			<cfset address &= arguments.addressLine2/>
		</cfif>

		<cfif Len(arguments.city) or Len(arguments.state) or Len(arguments.zipCode)>
			<cfif Len(address)>
				<cfset address &= "<br />"/>
			</cfif>

			<cfif Len(arguments.city)>
				<cfset address &= arguments.city/>

				 <cfif Len(arguments.state)>
					<cfset address &= ", "/>
				</cfif>
			</cfif>

			 <cfif Len(arguments.state)>
				<cfset address &= arguments.state/>
			</cfif>

			<cfif Len(arguments.zipCode)>
				<cfif Len(arguments.city) or Len(arguments.state)>
					<cfset address &= "&nbsp;&nbsp;"/>
				</cfif>

				<cfset address &= arguments.zipCode/>
			</cfif>
		</cfif>

		<cfreturn address/>
	</cffunction>

	<cffunction name="displayErrors" output="no">
		<cfargument name="open" default=""/>
		<cfargument name="close" default=""/>

		<cfset var local = StructNew()/>
		<cfset local.output = ""/>

		<cfif not StructKeyExists(arguments, "errors") and StructKeyExists(request.context, "errors")>
			<cfset arguments.errors = request.context.errors/>
		</cfif>

		<cfif StructKeyExists(arguments, "errors") and IsArray(arguments.errors) and not ArrayIsEmpty(arguments.errors)>
			<cfset local.output = arguments.open & "<div class=""error"">The following problems were found:</div><ul class=""error"">"/>
				<cfloop array="#arguments.errors#" index="local.error">
					<cfset local.output &= "<li>#local.error#</li>"/>
				</cfloop>
			<cfset local.output &= "</ul>" & arguments.close/>
		</cfif>
		<cfreturn local.output/>
	</cffunction>

	<cffunction name="getForm" output="no">
		<cfargument name="name" required="true"/>
		<cfreturn application.controller.getPlugin("forms").getForm(arguments.name)/>
	</cffunction>

</cfcomponent>