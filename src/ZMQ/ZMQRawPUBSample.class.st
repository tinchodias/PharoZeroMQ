Class {
	#name : #ZMQRawPUBSample,
	#superclass : #Object,
	#instVars : [
		'socket',
		'maxMessageSize'
	],
	#pools : [
		'ZMQConstants'
	],
	#category : #'ZMQ-Samples-Raw'
}

{ #category : #examples }
ZMQRawPUBSample class >> example [

	| url context publisher subscriber loremIpsum msgLength |
	"'12345' asFileReference ensureCreateFile. "
	"url := 'ipc://12345'."
	"url := 'inproc://#1'."
	url := 'tcp://127.0.0.1:31002'.

	msgLength := 5000.

	"Set up"
	context := ZMQContext new.
	publisher := ZMQRawPUBSample url: url context: context.
	subscriber := ZMQRawSUBSample url: url context: context.
	publisher maxMessageSize: msgLength.
	subscriber maxMessageSize: msgLength.

	loremIpsum := String loremIpsum: msgLength.
	[	|done|
		publisher publish: loremIpsum.
		done := false.
		[ subscriber
			receiveIfPresent: [ :r | done := true ]
			ifAbsent: [ Processor yield ]
			] doWhileFalse: [ done ]
		] bench traceCr.

	"tear down"
	subscriber socket close.
	publisher socket close.
	context destroy
]

{ #category : #accessing }
ZMQRawPUBSample class >> url: urlString [

	^ self url: urlString context: ZMQContext new
]

{ #category : #accessing }
ZMQRawPUBSample class >> url: urlString context: aZMQContext [

	^ self basicNew
		initializeSocket: 
			((ZMQSocket
				context: aZMQContext
				type: ZMQ_PUB)
				bind: urlString;
				yourself);
		yourself
]

{ #category : #configuration }
ZMQRawPUBSample >> initializeSocket: aZMQSocket [

	super initialize.

	socket := aZMQSocket.
	self maxMessageSize: 1400
]

{ #category : #accessing }
ZMQRawPUBSample >> maxMessageSize [

	^ maxMessageSize
]

{ #category : #configuration }
ZMQRawPUBSample >> maxMessageSize: anInteger [

	maxMessageSize := anInteger
]

{ #category : #API }
ZMQRawPUBSample >> publish: aByteArray [

	self assert: [ aByteArray size <= maxMessageSize ].
	
	ZMQLibraryInterface
		zmq_send: socket
		with: aByteArray
		with: aByteArray size
		with: 0
]

{ #category : #accessing }
ZMQRawPUBSample >> socket [

	^ socket
]
