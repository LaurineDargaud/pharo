Extension { #name : #AssemblyManifest }

{ #category : #'*Tool-DependencyAnalyser-UI' }
AssemblyManifest class >> includes: aPackageName [
	^ (self parts collect: [:each | each key]) 
		includes: aPackageName
]
