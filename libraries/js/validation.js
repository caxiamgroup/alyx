function FormValidation(id)
{
	this.id = id;
	this.errorMessages = new Array();
	this.errorClass = 'error';
	this.fields = new Object;
}

FormValidation.prototype.addField = function(name, required)
{
	this.fields[name] = new Object;
	this.fields[name].name = name;
	this.fields[name].required = required;
	this.fields[name].errorMessage = '';
}

FormValidation.prototype.isNotRequired = function(field)
{
	var fieldName = this.id + '_' + field;
	try 
	{
		return jQuery('#'+this.id+' *[name="'+fieldName+'"]').hasClass('notRequired');
	} 
	catch (e) 
	{
	}
	return false;
}

FormValidation.prototype.getValue = function(field)
{
	var fieldValue = "";
	var fieldName = this.id + '_' + field;

	if (!jQuery('#'+this.id+' *[name='+fieldName+']').length)
	{
		alert("The following field is defined in validation but is not present in the form.\n\nForm: " + this.id + "\nField: " + field);
	}
	var fieldObj = jQuery('#'+this.id+' *[name='+fieldName+']');
	if (fieldObj.attr('type') == null || fieldObj.attr('type') == "radio")
	{
		fieldValue = jQuery('#'+this.id+' input:radio[name='+fieldName+']:checked').val() || '';
	} 
	else if (fieldObj.attr('type') == "checkbox")
	{
		jQuery('#'+this.id+' input:checkbox[name='+fieldName+']:checked').each(function(){
			if(fieldValue != ""){
				fieldValue += ",";
			}
			fieldValue += $(this).val();
		});
	} 
	else
	{
		fieldValue = fieldObj.val();
	}

	return jQuery.trim(fieldValue);
}

FormValidation.prototype.addErrorMessage = function(msg, field)
{
	if (this.fields[field].errorMessage.length == 0) 
	{
		this.errorMessages.push(msg);
		if (field && this.errorClass) 
		{
			try
			{
				jQuery('#'+this.id+' *[name='+this.id+'_'+field+']').addClass(this.errorClass);
			}
			catch(e)
			{
				//ignore
			}
			this.fields[field].errorMessage = msg;
		}
	}
}

FormValidation.prototype.addErrorMessages = function(msg, fields)
{
	this.errorMessages.push(msg);
	var form = jQuery('#'+this.id);
	for (var i = 0; i < fields.length; ++i)
	{
		var field = fields[i];
		if (field && this.errorClass) 
		{
			try
			{
				jQuery('#'+this.id+' *['+this.id+'_'+field+']').addClass(this.errorClass);
			}
			catch(e)
			{
				//ignore
			}
			this.fields[field].errorMessage = msg;
		}
	}
}

FormValidation.prototype.scrollToMessage = function (errorMessageBlock)
{
	var position = $(errorMessageBlock).position();		 
	$('html, body').animate({scrollTop: $(errorMessageBlock).offset().top}, "fast");
} 

FormValidation.prototype.onValidationComplete = function()
{
	if (this.errorMessages.length)
	{
		var errorMessageBlock = $('#error-message-' + this.id).get(0);
		var output = 'The following problems were found:\n';
				 
		if (errorMessageBlock)
		{
			$(errorMessageBlock).show();
			
			output = '<div class="msg error"><p>'+output+'</p>\n<ul>';
			
			$(this.errorMessages).each(function(i,item){
				output += '\n' + '<li>' + item + '</li>';
			})
			
			output += '</ul></div>';
			
			$(errorMessageBlock).html(output);
			
			this.scrollToMessage(errorMessageBlock);
		}
		else
		{
			$(this.errorMessages).each(function(i,item){
				output += '\n' + item ;
			})
			alert(output);
		}
		
				
		return false;
	}
	return true;
}

FormValidation.prototype.clearErrorMessages = function()
{
	this.errorMessages.length = 0;
	var form = jQuery(this.id);
	for (var field in this.fields) 
	{
		try
		{
			jQuery('#'+this.id+'['+this.id+'_'+field+']').removeClass(this.errorClass);
		}
		catch(e)
		{
			//ignore
		}
		this.fields[field].errorMessage = '';
	}
}

FormValidation.prototype.fieldHasErrors = function(field)
{
	return (this.fields[field].errorMessage.length > 0); 
}

FormValidation.prototype.getFieldError = function(field)
{
	return this.fields[field].errorMessage; 
}

FormValidation.prototype.setFieldRequired = function(field)
{
	this.fields[field].required = 1; 
}

FormValidation.prototype.clearFieldRequired = function(field)
{
	this.fields[field].required = 0; 
}

FormValidation.prototype.setFieldErrorClass = function(errorClass)
{
	this.errorClass = errorClass;
}

var validationForms = new Object;

function getValidationForm(id)
{
	return validationForms[id];
}

function validateForm(form)
{
	var id = jQuery(form).attr("id");
	if (validationForms[id]) 
	{
		return validationForms[id].validate();
	}
	return true;
}

function validateRequired(form,field,errorMsg){
	if (!form.isNotRequired(field) && form.getValue(field) == ''){
		form.addErrorMessage(errorMsg, field);
	}
}
function validateMaxLength(form,field,maxLength,errorMsg){if(form.getValue(field).length>maxLength)form.addErrorMessage(errorMsg,field);}
function validateMinLength(form,field,minLength,errorMsg){var length=form.getValue(field).length;if(length>0&&length<minLength)form.addErrorMessage(errorMsg,field);}

