"
I am the glonal environment. The default is Smalltalk globals
"
Class {
	#name : #OCEnvironmentScope,
	#superclass : #OCAbstractScope,
	#instVars : [
		'environment'
	],
	#category : #'OpalCompiler-Core-Semantics'
}

{ #category : #'instance creation' }
OCEnvironmentScope class >> for: anEnvironment [  
	^self new environment: anEnvironment
]

{ #category : #accessing }
OCEnvironmentScope >> environment [
	^environment
]

{ #category : #accessing }
OCEnvironmentScope >> environment: aCollection [ 
	environment := aCollection
]

{ #category : #lookup }
OCEnvironmentScope >> hasBindingThatBeginsWith: aString [
	"check weather there are any bindings defined in the environment that start with aString"

	^environment hasBindingThatBeginsWith: aString

]

{ #category : #lookup }
OCEnvironmentScope >> lookupVar: name [
	"Return a var with this name.  Return nil if none found"
	name isString ifFalse: [ ^nil ].
	
	^environment bindingOf: name
]

{ #category : #creation }
OCEnvironmentScope >> newClassScope: aClass [

	^ (OCClassScope for: aClass) outerScope: self; yourself
]
