"
I am the OSWindowHandle interface implemented using SDL2 library

my handle is an SDL_Window
"
Class {
	#name : #OSSDL2BackendWindow,
	#superclass : #OSBackendWindow,
	#instVars : [
		'currentCursor',
		'iconSurface',
		'lastKeyboardFocus',
		'sdl2Window'
	],
	#pools : [
		'SDL2Constants'
	],
	#category : #'OSWindow-SDL2-Base'
}

{ #category : #'instance creation' }
OSSDL2BackendWindow class >> newWithHandle: handle attributes: attributes [
	^ self basicNew initWithHandle: handle attributes: attributes; yourself
]

{ #category : #accessing }
OSSDL2BackendWindow >> borderless [
	^ sdl2Window getFlags anyMask: SDL_WINDOW_BORDERLESS
]

{ #category : #accessing }
OSSDL2BackendWindow >> borderless: aBoolean [
	sdl2Window toggleBorder: aBoolean not.
]

{ #category : #accessing }
OSSDL2BackendWindow >> bounds: newBounds [
	self position: newBounds origin;
		extent: newBounds extent.
]

{ #category : #'mouse capture' }
OSSDL2BackendWindow >> captureMouse [
	SDL2 setRelativeMouseMode: true
]

{ #category : #accessing }
OSSDL2BackendWindow >> clipboardText [
	^ SDL2 clipboardText
]

{ #category : #accessing }
OSSDL2BackendWindow >> clipboardText: aText [
	SDL2 clipboardText: aText
]

{ #category : #'event handling' }
OSSDL2BackendWindow >> convertButtonState: mouseState modState: modState modifiers: modifiers [
	| shift ctrl alt ralt gui |
	modifiers buttons button1: (mouseState bitAnd: SDL_BUTTON_LMASK) ~= 0.
	modifiers buttons button2: (mouseState bitAnd: SDL_BUTTON_MMASK) ~= 0.
	modifiers buttons button3: (mouseState bitAnd: SDL_BUTTON_RMASK) ~= 0.
	modifiers buttons button4: (mouseState bitAnd: SDL_BUTTON_X1MASK) ~= 0.
	modifiers buttons button5: (mouseState bitAnd: SDL_BUTTON_X2MASK) ~= 0.

	shift := (modState bitAnd: KMOD_SHIFT) ~= 0.
	ctrl := (modState bitAnd: KMOD_CTRL) ~= 0.
	alt := (modState bitAnd: KMOD_LALT) ~= 0.
	ralt := (modState bitAnd: KMOD_RALT) ~= 0.
	gui := (modState bitAnd: KMOD_GUI) ~= 0.
    
	"Several keyboard layouts use AltGr to enter some symbols. In that case,
	the AltGr does not play role of a modifer and should be ignored. 
	As (hopefully) tempral solution, let's ignore all the modifiers if the AltGr is
	pressed (in this case, SDL adds Ctrl modifiers too).
	See https://github.com/pharo-project/pharo/issues/4745
	"
	ralt ifTrue: [ ^ self ].
    
	modifiers leftShift: shift; rightShift: shift;
		leftCtrl: ctrl; rightCtrl: ctrl;
		leftAlt: alt; rightAlt: ralt;
		leftCmd: gui; rightCmd: gui.
]

{ #category : #private }
OSSDL2BackendWindow >> convertCursor: aCursor [
	| result bits|
	aCursor unhibernate.
	bits := aCursor bits.
	result := ByteArray new: 32.
	0 to: 15 do: [ :i |
		result at: i*2 + 1 put: (bits at: i + 1) >> 24 & 255.
		result at: i*2 + 2 put: (bits at: i + 1) >> 16 & 255.
	].
	^ result
]

{ #category : #'event handling' }
OSSDL2BackendWindow >> deliverGlobalEvent: aGlobalEvent [
	^ osWindow deliverGlobalEvent: aGlobalEvent
]

{ #category : #initialize }
OSSDL2BackendWindow >> destroy [

	sdl2Window ifNotNil: [ :validHandle | 
		OSSDL2Driver current unregisterWindowWithId: validHandle windowID.
		validHandle destroy ].

	renderer := nil.
	sdl2Window := nil.
	osWindow := nil
]

{ #category : #accessing }
OSSDL2BackendWindow >> extent [
	| w h |
	w := ByteArray new: 4.
	h := ByteArray new: 4.
	sdl2Window getSizeW: w h: h.
	^ (w signedLongAt: 1) @ (h signedLongAt: 1)
]

{ #category : #accessing }
OSSDL2BackendWindow >> extent: newExtent [
	sdl2Window setSizeW: newExtent x h: newExtent y
]

{ #category : #accessing }
OSSDL2BackendWindow >> fullscreen: aBoolean [
	aBoolean ifTrue: [
		sdl2Window fullscreen: SDL_WINDOW_FULLSCREEN_DESKTOP
	] ifFalse: [ 
		sdl2Window fullscreen: 0
	]
]

{ #category : #private }
OSSDL2BackendWindow >> getFlags [
	^ sdl2Window getFlags
]

{ #category : #private }
OSSDL2BackendWindow >> getWMInfo [
	| wmInfo |
	wmInfo := SDL_SysWMinfo new version: SDL_Version bindingVersion.
	sdl2Window getWMInfo: wmInfo.
	^ wmInfo
]

{ #category : #'event handling' }
OSSDL2BackendWindow >> handleNewSDLEvent: sdlEvent [
	^ sdlEvent accept: self
]

{ #category : #accessing }
OSSDL2BackendWindow >> hide [
	sdl2Window hide
]

{ #category : #accessing }
OSSDL2BackendWindow >> icon: aForm [
	| convertedIcon surface |
	aForm ifNil: [ ^self ].
	
	convertedIcon := aForm unhibernate; asFormOfDepth: 32.
	surface := SDL2 createRGBSurfaceFromPixels: convertedIcon bits
			width: convertedIcon width height: convertedIcon height
			depth: 32 pitch: convertedIcon width *4
			rmask: 16r00ff0000 
			gmask: 16r000ff00
			bmask: 16r00000ff
			amask: 16rff000000.
	sdl2Window icon: surface.
	iconSurface ifNotNil: [ SDL2 freeSurface: surface ].
	iconSurface := surface.
]

{ #category : #initialize }
OSSDL2BackendWindow >> initWithHandle: aHandle attributes: attributes [
	sdl2Window := aHandle.
	attributes applyTo: self
]

{ #category : #initialization }
OSSDL2BackendWindow >> initialize [
	
	self class initializeSlots: self.
	super initialize.
]

{ #category : #'text input' }
OSSDL2BackendWindow >> isTextInputActive [
	"See https://wiki.libsdl.org/SDL_IsTextInputActive"

	^ sdl2Window isTextInputActive
]

{ #category : #testing }
OSSDL2BackendWindow >> isValid [
	^ true
]

{ #category : #testing }
OSSDL2BackendWindow >> isVisible [
	^ (self getFlags bitAnd: SDL_WINDOW_SHOWN) = SDL_WINDOW_SHOWN
]

{ #category : #'event handling' }
OSSDL2BackendWindow >> mapSpecialCharacter: symbol [
	^ SDL2SpecialCharacterMapping mapKeySymbol: symbol ifAbsent: [ ^ nil ]
]

{ #category : #'window management' }
OSSDL2BackendWindow >> maximize [

	sdl2Window maximize.
]

{ #category : #'window management' }
OSSDL2BackendWindow >> minimize [

	sdl2Window minimize.
]

{ #category : #'event handling' }
OSSDL2BackendWindow >> mousePosition [
	| x y |
	x := ByteArray new: 4.
	y := ByteArray new: 4.
	SDL2 mouseStateX: x y: y.
	^ ( x signedLongAt: 1) @ (y signedLongAt: 1)
]

{ #category : #'instance creation' }
OSSDL2BackendWindow >> newAthensRenderer [
	^ renderer := OSSDL2AthensRenderer for: self.
]

{ #category : #'instance creation' }
OSSDL2BackendWindow >> newFormRenderer: form [
	^ renderer := OSSDL2FormRenderer new 
		form: form;
		backendWindow: self;
		yourself
]

{ #category : #'instance creation' }
OSSDL2BackendWindow >> newGenericRenderer [
	^ renderer := OSSDL2GenericRenderer new 
		backendWindow: self;
		createSDL2Renderer;
		yourself
]

{ #category : #'instance creation' }
OSSDL2BackendWindow >> newOpenGLRenderer [
	^ renderer := OSSDL2GLRenderer new 
		backendWindow: self;
		createContext;
		yourself
]

{ #category : #accessing }
OSSDL2BackendWindow >> platformSpecificHandle [
	| wmInfo platformID |
	wmInfo := self getWMInfo.
	platformID := wmInfo subsystem.
	platformID = SDL_SYSWM_WINDOWS ifTrue: [ ^ wmInfo info win asPlatformSpecificHandle ].
	platformID = SDL_SYSWM_X11 ifTrue: [ ^ wmInfo info x11 asPlatformSpecificHandle ].
	platformID = SDL_SYSWM_DIRECTFB ifTrue: [ ^ wmInfo info dfb asPlatformSpecificHandle ].
	platformID = SDL_SYSWM_COCOA ifTrue: [ ^ wmInfo info cocoa asPlatformSpecificHandle ].
	platformID = SDL_SYSWM_UIKIT ifTrue: [ ^ wmInfo info uikit asPlatformSpecificHandle ].
	platformID = SDL_SYSWM_WAYLAND ifTrue: [ ^ wmInfo info wl asPlatformSpecificHandle ].
	platformID = SDL_SYSWM_MIR ifTrue: [ ^ wmInfo info mir asPlatformSpecificHandle ].
	platformID = SDL_SYSWM_WINRT ifTrue: [ ^ wmInfo info winrt asPlatformSpecificHandle ].
	platformID = SDL_SYSWM_ANDROID ifTrue: [ ^ wmInfo info android asPlatformSpecificHandle ].
	
	self error: 'Trying to get a platform specific handle for an unsupported SDL2 platform.'
]

{ #category : #accessing }
OSSDL2BackendWindow >> position [
	| x y |
	x := ByteArray new: ExternalType long byteSize.
	y := ByteArray new: ExternalType long byteSize.
	sdl2Window getPositionX: x y: y.
	^ ( x signedLongAt: 1) @ (y signedLongAt: 1)
]

{ #category : #accessing }
OSSDL2BackendWindow >> position: aPoint [
	sdl2Window setPositionX: aPoint x asInteger y: aPoint y asInteger
]

{ #category : #accessing }
OSSDL2BackendWindow >> prepareExternalResourceForAutoRelease [
	sdl2Window autoRelease
]

{ #category : #accessing }
OSSDL2BackendWindow >> raise [

	sdl2Window raise
]

{ #category : #'mouse capture' }
OSSDL2BackendWindow >> releaseMouse [
	SDL2 setRelativeMouseMode: false
]

{ #category : #accessing }
OSSDL2BackendWindow >> resizable [
	^ sdl2Window getFlags anyMask: SDL_WINDOW_RESIZABLE
]

{ #category : #accessing }
OSSDL2BackendWindow >> resizable: aBoolean [
	"This is not supported."
]

{ #category : #'window management' }
OSSDL2BackendWindow >> restore [

	sdl2Window restore
]

{ #category : #initialize }
OSSDL2BackendWindow >> sdl2Window [

	^ sdl2Window
]

{ #category : #'window management' }
OSSDL2BackendWindow >> setDraggableArea: aRectangle [

	| myCallback sdlRect |
	
	sdlRect := aRectangle asSDLRect.
	
	myCallback := DraggableCallback on: [ :aWindow :pt :data |
			(pt x > sdlRect x) & (pt x < sdlRect w) & (pt y > sdlRect y) & (pt y < sdlRect h) ifTrue: [ 1 ] ifFalse: [ 0 ].
		].
	
	^sdl2Window setHitTest: myCallback.
]

{ #category : #cursor }
OSSDL2BackendWindow >> setMouseCursor: cursor mask: mask [
	| cursorBits maskBits extent offset sdlCursor |
	cursorBits := self convertCursor: cursor.
	maskBits := self convertCursor: mask.
	extent := cursor extent.
	offset := cursor offset.
	sdlCursor := SDL2 createCursor: cursorBits mask: maskBits w: extent x h: extent y hotX: offset x negated hotY: offset y negated.
	sdlCursor ifNotNil: [ sdlCursor setCursor ].
	currentCursor ifNotNil: [ currentCursor freeCursor ].
	currentCursor := sdlCursor
]

{ #category : #accessing }
OSSDL2BackendWindow >> show [
	sdl2Window show
]

{ #category : #cursor }
OSSDL2BackendWindow >> showCursor: aBoolean [
	SDL2 showCursor: (aBoolean ifTrue: [SDL_ENABLE] ifFalse: [SDL_DISABLE]).
]

{ #category : #'text input' }
OSSDL2BackendWindow >> startTextInput [
	"See https://wiki.libsdl.org/SDL_StartTextInput"

	sdl2Window startTextInput
]

{ #category : #'text input' }
OSSDL2BackendWindow >> stopTextInput [
	"See https://wiki.libsdl.org/SDL_StopTextInput"

	sdl2Window stopTextInput
]

{ #category : #accessing }
OSSDL2BackendWindow >> title [
	^ sdl2Window title
]

{ #category : #accessing }
OSSDL2BackendWindow >> title: aTitle [
	sdl2Window title: aTitle
]

{ #category : #'window management' }
OSSDL2BackendWindow >> toggleBorderOff [

	sdl2Window toggleBorder: false.
]

{ #category : #'window management' }
OSSDL2BackendWindow >> toggleBorderOn [

	sdl2Window toggleBorder: true.
]

{ #category : #'event handling' }
OSSDL2BackendWindow >> visitKeyDownEvent: event [
	| osEvent keysym |
	keysym := event keysym.
	osEvent := OSKeyDownEvent for: osWindow.
	osEvent scanCode: keysym scancode;
			symbol: keysym sym;
			repeat: event repeat;
			position: self mousePosition;
			character: (self mapSpecialCharacter: keysym sym).
			
	self convertButtonState: SDL2 mouseState modState: keysym mod modifiers: osEvent modifiers.
	^ osEvent deliver.
]

{ #category : #'event handling' }
OSSDL2BackendWindow >> visitKeyUpEvent: event [
	| osEvent keysym |
	keysym := event keysym.
	osEvent := OSKeyUpEvent for: osWindow.
	osEvent scanCode: keysym scancode;
			symbol: keysym sym;
			repeat: event repeat;
			position: self mousePosition.
			
	self convertButtonState: SDL2 mouseState modState: keysym mod modifiers: osEvent modifiers.
	^ osEvent deliver.
]

{ #category : #'event handling' }
OSSDL2BackendWindow >> visitMouseButtonDownEvent: event [
	| osEvent |
	osEvent := OSMouseButtonPressEvent for: osWindow.
	osEvent button: event button;
			position: event x @ event y.
	
	self convertButtonState: SDL2 mouseState modState: SDL2 modState modifiers: osEvent modifiers.
	^ osEvent deliver.
]

{ #category : #'event handling' }
OSSDL2BackendWindow >> visitMouseButtonUpEvent: event [
	| osEvent |
	osEvent := OSMouseButtonReleaseEvent for: osWindow.
	osEvent button: event button;
			position: event x @ event y.
	
	self convertButtonState: SDL2 mouseState modState: SDL2 modState modifiers: osEvent modifiers.
	^ osEvent deliver.
]

{ #category : #'event handling' }
OSSDL2BackendWindow >> visitMouseMotionEvent: sdlEvent [
	| osEvent |
	osEvent := OSMouseMoveEvent for: osWindow.
	osEvent position: sdlEvent x @ sdlEvent y;
		delta: sdlEvent xrel @ sdlEvent yrel.

	self convertButtonState: sdlEvent state modState: SDL2 modState modifiers: osEvent modifiers.
	^ osEvent deliver.
]

{ #category : #'event handling' }
OSSDL2BackendWindow >> visitMouseWheelEvent: sdlEvent [
	| osEvent |
	osEvent := OSMouseWheelEvent for: osWindow.
	osEvent position: self mousePosition;
			scrollHorizontal: sdlEvent x;
			scrollVertical: sdlEvent y.
			
	self convertButtonState: SDL2 mouseState modState: SDL2 modState modifiers: osEvent modifiers.
	^ osEvent deliver.
]

{ #category : #'event handling' }
OSSDL2BackendWindow >> visitTextInputEvent: event [
	| osEvent |
	
	osEvent := OSTextInputEvent for: osWindow.
	osEvent text: (ZnUTF8Encoder new decodeBytes: event text);
			position: self mousePosition.
			
	self convertButtonState: SDL2 mouseState modState: SDL2 modState modifiers: osEvent modifiers.
	^ osEvent deliver.
]

{ #category : #'event handling' }
OSSDL2BackendWindow >> visitWindowEvent: windowEvent [
	osWindow ifNil: [ ^self ].
	
	windowEvent event = SDL_WINDOWEVENT_EXPOSED ifTrue: [
		^ ((OSWindowExposeEvent for: osWindow) timestamp: windowEvent timestamp) deliver ].
	windowEvent event = SDL_WINDOWEVENT_HIDDEN ifTrue: [ 
		^ (OSWindowHiddenEvent for: osWindow) deliver ].
	windowEvent event = SDL_WINDOWEVENT_SHOWN ifTrue: [ 
		^ ((OSWindowShownEvent for: osWindow) timestamp: windowEvent timestamp) deliver ].
	windowEvent event = SDL_WINDOWEVENT_CLOSE ifTrue: [ 
		^ (OSWindowCloseEvent for: osWindow) deliver ].
	windowEvent event = SDL_WINDOWEVENT_MOVED ifTrue: [ 
		^ (OSWindowMoveEvent for: osWindow) deliver ].
	windowEvent event = SDL_WINDOWEVENT_RESIZED ifTrue: [ 
		^ (OSWindowResizeEvent for: osWindow)
				width: windowEvent data1;
				height: windowEvent data2;
				deliver ].
	windowEvent event = SDL_WINDOWEVENT_ENTER ifTrue: [ 
		^ (OSWindowMouseEnterEvent for: osWindow) deliver ].
	windowEvent event = SDL_WINDOWEVENT_LEAVE ifTrue: [ 
		^ (OSWindowMouseLeaveEvent for: osWindow) deliver ].
	windowEvent event = SDL_WINDOWEVENT_FOCUS_GAINED ifTrue: [ 
		^ (OSWindowFocusInEvent for: osWindow) deliver ].
	windowEvent event = SDL_WINDOWEVENT_FOCUS_LOST ifTrue: [ 
		^ (OSWindowFocusOutEvent for: osWindow) deliver ].
	windowEvent event = SDL_WINDOWEVENT_MAXIMIZED ifTrue: [ 
		^ (OSWindowMaximizedEvent for: osWindow) deliver ].
	windowEvent event = SDL_WINDOWEVENT_MINIMIZED ifTrue: [ 
		^ (OSWindowMinimizedEvent for: osWindow) deliver ]
]

{ #category : #accessing }
OSSDL2BackendWindow >> windowId [
	^ self sdl2Window windowID
]
