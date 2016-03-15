// see http://doc.sccode.org/Guides/WritingClasses.html

HelloWorld : Object {
	var name, <>lastName;
	*classMethod { "Hello World!".postln }
	instanceMethod	{ "This is from an instance of HelloWorld".postln; }
	name { ^name }
	setName {arg newName; name = newName}
}