/*
 * jQuery Extensions 1.0
 * http://code.google.com/p/jquery-extensions/
 *
 * Copyright (c) 2009 C.Small
 *
 * Licensed under the MIT license.
 * Date: 21:31 20/05/2009
 */
 
/* Determines whether the object is a Javascript Number object (int or float)
	@param The object to compare.
*/
jQuery.isNumber = function(o)
{
	///	<summary>
	///	Determines whether the object is a Javascript Number object (int or float)
	///	</summary>
	///	<param name="o" type="Object">The object to compare.</param>
	///	<returns type="Boolean" />
	if (typeof o == "object" && o !== null)
		return (typeof o.valueOf() === "number")
    else
		return (typeof o === "number");
}

/* Determines whether the object is a Javascript boolean object. Only true and false will return true for this function.
	@param The object to compare.
*/
jQuery.isBoolean = function(o)
{
	///	<summary>
	///	Determines whether the object is a Javascript boolean object. Only true and false will return true for this function.
	///	</summary>
	///	<param name="o" type="Object">The object to compare.</param>
	///	<returns type="Boolean" />
	if (typeof o == "object" && o !== null)
		return (typeof o.valueOf() === "boolean")
    else
		return (typeof o === "boolean");
}

/* Determines whether the object is null (declare variables with a value set to null). This will return false for undefined values.
	@param The object to compare.
*/
jQuery.isNull = function(o)
{
	///	<summary>
	///	Determines whether the object is null (declare variables with a value set to null). This will return false for undefined values.
	///	</summary>
	///	<param name="o" type="Object">The object to compare.</param>
	///	<returns type="Boolean" />
	return (o === null);
}

/* Determines whether the object is undefined, that is no value has been set for it. This will return false for variables with null value.
	@param The object to compare.
*/
jQuery.isUndefined = function(o)
{
	///	<summary>
	///	Determines whether the object is undefined, that is no value has been set for it. This will return false for variables with null value.
	///	</summary>
	///	<param name="o" type="Object">The object to compare.</param>
	///	<returns type="Boolean" />
	return (typeof o === "undefined");
}

/* Determines whether the object provided is null, or undefined.
	@param The object to compare.
*/
jQuery.isNullOrUndefined = function(o)
{
	///	<summary>
	///	Determines whether the object provided is null, or undefined.
	///	</summary>
	///	<param name="o" type="Object">The object to compare.</param>
	///	<returns type="Boolean" />
	return jQuery.isNull(o) || jQuery.isUndefined(o);
}

/* Determines whether the object is a Javascript string object.
	@param The object to compare.
*/
jQuery.isString = function(o)
{
	///	<summary>
	///	Determines whether the object is a Javascript string object.
	///	</summary>
	///	<param name="o" type="Object">The object to compare.</param>
	///	<returns type="Boolean" />
	return (typeof o === "string");
}

/* Determines whether the object is a Javascript Array object (declared as [] or new Array()).
	@param The object to compare.
*/
jQuery.isArray = function(o)
{
	///	<summary>
	///	Determines whether the object is a Javascript Array object (declared as [] or new Array()).
	///	</summary>
	///	<param name="o" type="Object">The object to compare.</param>
	///	<returns type="Boolean" />
	// This is based on code from prototype
	return (o != null && typeof o == "object" && "splice" in o && "join" in o);
}

/* Determines whether the object is a Javascript string object, and is empty - that is zero length.
   Undefined and null objects return false.
	@param The string to compare.
*/
jQuery.emptyString = function(str)
{
	///	<summary>
	///	Determines whether the object is a Javascript string object, and is empty - that is zero length.
	/// Undefined and null objects return false.
	///	</summary>
	///	<param name="str" type="String">The string to compare.</param>
	///	<returns type="Boolean" />
	if (jQuery.isNullOrUndefined(str))
		return true;
	else if (!jQuery.isString(str))
		throw "isEmpty: the object is not a string";
	else if (str.length === 0)
		return true;
		
	return false;
}

/* Determines whether a string starts with a particular other string.
	@param str The string to search.
	@param search The string to search for.
*/
jQuery.startsWith = function(str,search)
{
	///	<summary>
	///	 Determines whether a string starts with a particular other string.
	///	</summary>
	///	<param name="str" type="String">The string to search.</param>
	///	<param name="search" type="String">The string to search for.</param>
	///	<returns type="Boolean" />
	if (jQuery.isString(str))
		return (str.indexOf(search) === 0);
		
	return false;
}

/* Determines whether a string ends with a particular other string.
	@param str The string to search.
	@param search The string to search for.
*/
jQuery.endsWith = function(str,search)
{
	///	<summary>
	///	Determines whether a string ends with a particular other string.
	///	</summary>
	///	<param name="str" type="String">The string to search.</param>
	///	<param name="search" type="String">The string to search for.</param>
	///	<returns type="Boolean" />
	if (!jQuery.isString(str) || !jQuery.isString(search) || jQuery.emptyString(str) || jQuery.emptyString(search))
		return false;
	else if (search.length > str.length)
		return false;
	else if (str.length - search.length === str.lastIndexOf(search))
		return true;
	
	return false;
}

/* Determines whether a string ends with a particular other string.
	Example:
	jQuery.formatString("Hello {0} it's {1}, you owe me ${2}","bob","Tuesday",3.00);
	
	If no tokens are found, the format string is returned.
	
	@param args A list of objects to display. The first argument should be the format - using
	.NET syntax of {0}, {1} and so on for replacements. These tokens are then replaced with the
	arguments matching their number (and their toString() method is used to print out the value).
*/
jQuery.formatString = function()
{
	///	<summary>
	///	Determines whether a string ends with a particular other string.
	///	Example:
	///	jQuery.formatString("Hello {0} it's {1}, you owe me ${2}","bob","Tuesday",3.00);
	///	
	///	If no tokens are found, the format string is returned.
	///	</summary>
	///	<param name="args" type="Array">A list of objects to display. The first argument should be the format - using
	///	.NET syntax of {0}, {1} and so on for replacements. These tokens are then replaced with the
	///	arguments matching their number (and their toString() method is used to print out the value).</param>
	///	<returns type="String" />
	if (arguments.length < 2)
		return "";
	
	var str = arguments[0];
	for (var i = 1; i < arguments.length; i++)
	{
		var val = "";
		if (!jQuery.isNullOrUndefined(val))
			val = arguments[i] +""; // avoid toString
		
		var regex = new RegExp("\\{"+(i -1)+ "\\}","g");
		str = str.replace(regex,val);
	}
	
	return str;
}

/* Provides basic logging. The provided format string and arguments (see jQuery.formatString) are logged to the console, if supported
   (IE8 or Firefox 3.x support console logging)
   @param args A format string and then a list of objects to display. See jQuery.formatString for more information.
*/
jQuery.log = function()
{
	///	<summary>
	///	Provides basic logging. The provided format string and arguments (see formatString) are logged to the console, if supported
	/// (IE8 or Firefox 3.x support console logging)
	///	</summary>
	///	<param name="args" type="Array">A format string and then a list of objects to display. See jQuery.formatString for more information.</param>
	
	if (typeof console !== "undefined")
	{
		console.log(jQuery.formatString.apply(this,arguments));
	}
}