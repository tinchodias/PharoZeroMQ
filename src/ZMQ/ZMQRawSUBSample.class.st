Class {
	#name : #ZMQRawSUBSample,
	#superclass : #Object,
	#instVars : [
		'socket',
		'buffer',
		'maxMessageSize'
	],
	#pools : [
		'ZMQConstants'
	],
	#category : #'ZMQ-Samples-Raw'
}

{ #category : #accessing }
ZMQRawSUBSample class >> url: urlString [

	^ self url: urlString context: ZMQContext new
]

{ #category : #accessing }
ZMQRawSUBSample class >> url: urlString context: aZMQContext [

	^ self basicNew
		initializeSocket: 
			((ZMQSocket
				context: aZMQContext
				type: ZMQ_SUB)
				connect: urlString;
				optionKey: ZMQ_SUBSCRIBE optValue: '';
				yourself);
		yourself
]

{ #category : #accessing }
ZMQRawSUBSample >> buffer [

	^ buffer
]

{ #category : #initialization }
ZMQRawSUBSample >> initializeSocket: aZMQSocket [

	super initialize.

	socket := aZMQSocket.
	
	self maxMessageSize: 1400
]

{ #category : #accessing }
ZMQRawSUBSample >> maxMessageSize [

	^ maxMessageSize
]

{ #category : #initialization }
ZMQRawSUBSample >> maxMessageSize: anInteger [

	maxMessageSize := anInteger.
	buffer := ByteArray new: maxMessageSize
]

{ #category : #API }
ZMQRawSUBSample >> receiveIfPresent: presentBlock ifAbsent: absentBlock [

	| messageSize |
	messageSize :=
		ZMQLibraryInterface
			zmq_recv: socket
			with: buffer
			with: maxMessageSize
			with: ZMQ_DONTWAIT.

	^ messageSize = -1
		ifTrue: [
			"Check if there is any enqueued message"
			(#(11 35) includes: ZMQLibraryInterface zmq_errno)
				ifTrue: [ absentBlock value ]
				ifFalse: [ 
					self error: (ZMQLibraryInterface zmq_strerror: ZMQLibraryInterface zmq_errno) ] ]
		ifFalse: [
			presentBlock value: (ReadStream on: buffer from: 1 to: messageSize) ]
]

{ #category : #accessing }
ZMQRawSUBSample >> socket [

	^ socket
]
