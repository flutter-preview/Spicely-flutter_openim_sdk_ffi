/* Code generated by cmd/cgo; DO NOT EDIT. */

/* package command-line-arguments */


#line 1 "cgo-builtin-export-prolog"

#include <stddef.h>

#ifndef GO_CGO_EXPORT_PROLOGUE_H
#define GO_CGO_EXPORT_PROLOGUE_H

#ifndef GO_CGO_GOSTRING_TYPEDEF
typedef struct { const char *p; ptrdiff_t n; } _GoString_;
#endif

#endif

/* Start of preamble from import "C" comments.  */


#line 3 "flutter_openim_sdk_ffi.go"

#include <stdint.h>
#include <stdlib.h>

typedef void (*OnErrorFuncFunc)();
typedef void (*OnConnectSuccessFunc)();
typedef void (*OnConnectFailedFunc)(int32_t* errCode, const char* errMsg);
typedef void (*OnKickedOfflineFunc)();
typedef void (*OnUserTokenExpiredFunc)();

typedef struct {
 	OnErrorFuncFunc  onConnecting;
    OnConnectSuccessFunc onConnectSuccess;
    OnConnectFailedFunc onConnectFailed;
    OnKickedOfflineFunc onKickedOffline;
   	OnUserTokenExpiredFunc onUserTokenExpired;
} ConnListener;

typedef void (*OnErrorFunc)(int32_t* errCode, const char* errMsg);
typedef void (*OnSuccessFunc)(const char* data);

typedef struct {
	OnErrorFunc onError;
	OnSuccessFunc onSuccess;
} BaseListener;

typedef void (*OnSelfInfoUpdatedFunc)(const char* userInfo);

typedef struct {
    OnSelfInfoUpdatedFunc onSelfInfoUpdated;
} UserListener;

typedef void (*OnRecvNewMessageFunc)(const char* message);
typedef void (*OnRecvC2CReadReceiptFunc)(const char* msgReceiptList);
typedef void (*OnRecvGroupReadReceiptFunc)(const char* groupMsgReceiptList);
typedef void (*OnNewRecvMessageRevokedFunc)(const char* messageRevoked);
typedef void (*OnRecvMessageExtensionsChangedFunc)(const char* msgID, const char* reactionExtensionList);
typedef void (*OnRecvMessageExtensionsDeletedFunc)(const char* msgID, const char* reactionExtensionKeyList);
typedef void (*OnRecvMessageExtensionsAddedFunc)(const char* msgID, const char* reactionExtensionList);
typedef void (*OnRecvOfflineNewMessagesFunc)(const char* messageList);
typedef void (*OnMsgDeletedFunc)(const char* message);

typedef struct {
    OnRecvNewMessageFunc onRecvNewMessage;
    OnRecvC2CReadReceiptFunc onRecvC2CReadReceipt;
    OnRecvGroupReadReceiptFunc onRecvGroupReadReceipt;
    OnNewRecvMessageRevokedFunc onNewRecvMessageRevoked;
    OnRecvMessageExtensionsChangedFunc onRecvMessageExtensionsChanged;
    OnRecvMessageExtensionsDeletedFunc onRecvMessageExtensionsDeleted;
    OnRecvMessageExtensionsAddedFunc onRecvMessageExtensionsAdded;
    OnRecvOfflineNewMessagesFunc onRecvOfflineNewMessages;
    OnMsgDeletedFunc onMsgDeleted;
} AdvancedMsgListener;

typedef void (*OnFriendApplicationAddedFunc)(const char* friendApplication);
typedef void (*OnFriendApplicationDeletedFunc)(const char* friendApplication);
typedef void (*OnFriendApplicationAcceptedFunc)(const char* friendApplication);
typedef void (*OnFriendApplicationRejectedFunc)(const char* friendApplication);
typedef void (*OnFriendAddedFunc)(const char* friendInfo);
typedef void (*OnFriendDeletedFunc)(const char* friendInfo);
typedef void (*OnFriendInfoChangedFunc)(const char* friendInfo);
typedef void (*OnBlackAddedFunc)(const char* blackInfo);
typedef void (*OnBlackDeletedFunc)(const char* blackInfo);

typedef struct {
    OnFriendApplicationAddedFunc onFriendApplicationAdded;
    OnFriendApplicationDeletedFunc onFriendApplicationDeleted;
    OnFriendApplicationAcceptedFunc onFriendApplicationAccepted;
    OnFriendApplicationRejectedFunc onFriendApplicationRejected;
    OnFriendAddedFunc onFriendAdded;
    OnFriendDeletedFunc onFriendDeleted;
    OnFriendInfoChangedFunc onFriendInfoChanged;
    OnBlackAddedFunc onBlackAdded;
    OnBlackDeletedFunc onBlackDeleted;
} FriendshipListener;

typedef void (*OnSyncServerStartFunc)();
typedef void (*OnSyncServerFinishFunc)();
// typedef void (*OnSyncServerProgressFunc)(int progress);
typedef void (*OnSyncServerFailedFunc)();
typedef void (*OnNewConversationFunc)(const char* conversationList);
typedef void (*OnConversationChangedFunc)(const char* conversationList);
typedef void (*OnTotalUnreadMessageCountChangedFunc)(int32_t* totalUnreadCount);

typedef struct {
    OnSyncServerStartFunc onSyncServerStart;
    OnSyncServerFinishFunc onSyncServerFinish;
    // OnSyncServerProgressFunc onSyncServerProgress;
    OnSyncServerFailedFunc onSyncServerFailed;
    OnNewConversationFunc onNewConversation;
    OnConversationChangedFunc onConversationChanged;
    OnTotalUnreadMessageCountChangedFunc onTotalUnreadMessageCountChanged;
} ConversationListener;

typedef void (*OnReceiveNewInvitationFunc)(const char* receiveNewInvitationCallback);
typedef void (*OnInviteeAcceptedFunc)(const char* inviteeAcceptedCallback);
typedef void (*OnInviteeAcceptedByOtherDeviceFunc)(const char* inviteeAcceptedCallback);
typedef void (*OnInviteeRejectedFunc)(const char* inviteeRejectedCallback);
typedef void (*OnInviteeRejectedByOtherDeviceFunc)(const char* inviteeRejectedCallback);
typedef void (*OnInvitationCancelledFunc)(const char* invitationCancelledCallback);
typedef void (*OnInvitationTimeoutFunc)(const char* invitationTimeoutCallback);
typedef void (*OnHangUpFunc)(const char* hangUpCallback);
typedef void (*OnRoomParticipantConnectedFunc)(const char* onRoomParticipantConnectedCallback);
typedef void (*OnRoomParticipantDisconnectedFunc)(const char* onRoomParticipantDisconnectedCallback);

typedef struct {
    OnReceiveNewInvitationFunc onReceiveNewInvitation;
    OnInviteeAcceptedFunc onInviteeAccepted;
    OnInviteeAcceptedByOtherDeviceFunc onInviteeAcceptedByOtherDevice;
    OnInviteeRejectedFunc onInviteeRejected;
    OnInviteeRejectedByOtherDeviceFunc onInviteeRejectedByOtherDevice;
    OnInvitationCancelledFunc onInvitationCancelled;
    OnInvitationTimeoutFunc onInvitationTimeout;
    OnHangUpFunc onHangUp;
    OnRoomParticipantConnectedFunc onRoomParticipantConnected;
    OnRoomParticipantDisconnectedFunc onRoomParticipantDisconnected;
} SignalingListener;


#line 1 "cgo-generated-wrapper"


/* End of preamble from import "C" comments.  */


/* Start of boilerplate cgo prologue.  */
#line 1 "cgo-gcc-export-header-prolog"

#ifndef GO_CGO_PROLOGUE_H
#define GO_CGO_PROLOGUE_H

typedef signed char GoInt8;
typedef unsigned char GoUint8;
typedef short GoInt16;
typedef unsigned short GoUint16;
typedef int GoInt32;
typedef unsigned int GoUint32;
typedef long long GoInt64;
typedef unsigned long long GoUint64;
typedef GoInt64 GoInt;
typedef GoUint64 GoUint;
typedef size_t GoUintptr;
typedef float GoFloat32;
typedef double GoFloat64;
#ifdef _MSC_VER
#include <complex.h>
typedef _Fcomplex GoComplex64;
typedef _Dcomplex GoComplex128;
#else
typedef float _Complex GoComplex64;
typedef double _Complex GoComplex128;
#endif

/*
  static assertion to make sure the file is being used on architecture
  at least with matching size of GoInt.
*/
typedef char _check_for_64_bit_pointer_matching_GoInt[sizeof(void*)==64/8 ? 1:-1];

#ifndef GO_CGO_GOSTRING_TYPEDEF
typedef _GoString_ GoString;
#endif
typedef void *GoMap;
typedef void *GoChan;
typedef struct { void *t; void *v; } GoInterface;
typedef struct { void *data; GoInt len; GoInt cap; } GoSlice;

#endif

/* End of boilerplate cgo prologue.  */

#ifdef __cplusplus
extern "C" {
#endif

extern _Bool InitSDK(ConnListener* listener, char* operationID, char* config);
extern void Login(BaseListener* callback, char* operationID, char* userID, char* token);
extern void SetUserListener(UserListener* listener);
extern void SetAdvancedMsgListener(AdvancedMsgListener* listener);
extern void SetFriendListener(FriendshipListener* listener);
extern void SetConversationListener(ConversationListener* listener);
extern void SetSignalingListener(SignalingListener* listener);
extern char* GetSdkVersion();

#ifdef __cplusplus
}
#endif
