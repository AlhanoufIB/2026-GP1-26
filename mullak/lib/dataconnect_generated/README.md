# dataconnect_generated SDK

## Installation
```sh
flutter pub get firebase_data_connect
flutterfire configure
```
For more information, see [Flutter for Firebase installation documentation](https://firebase.google.com/docs/data-connect/flutter-sdk#use-core).

## Data Connect instance
Each connector creates a static class, with an instance of the `DataConnect` class that can be used to connect to your Data Connect backend and call operations.

### Connecting to the emulator

```dart
String host = 'localhost'; // or your host name
int port = 9399; // or your port number
MullakConnector.instance.dataConnect.useDataConnectEmulator(host, port);
```

You can also call queries and mutations by using the connector class.
## Queries

### GetMyProfile
#### Required Arguments
```dart
// No required arguments
MullakConnector.instance.getMyProfile().execute();
```



#### Return Type
`execute()` returns a `QueryResult<GetMyProfileData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await MullakConnector.instance.getMyProfile();
GetMyProfileData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = MullakConnector.instance.getMyProfile().ref();
ref.execute();

ref.subscribe(...);
```


### ListAvailableProperties
#### Required Arguments
```dart
// No required arguments
MullakConnector.instance.listAvailableProperties().execute();
```



#### Return Type
`execute()` returns a `QueryResult<ListAvailablePropertiesData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await MullakConnector.instance.listAvailableProperties();
ListAvailablePropertiesData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = MullakConnector.instance.listAvailableProperties().ref();
ref.execute();

ref.subscribe(...);
```


### ListMyProperties
#### Required Arguments
```dart
// No required arguments
MullakConnector.instance.listMyProperties().execute();
```



#### Return Type
`execute()` returns a `QueryResult<ListMyPropertiesData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await MullakConnector.instance.listMyProperties();
ListMyPropertiesData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = MullakConnector.instance.listMyProperties().ref();
ref.execute();

ref.subscribe(...);
```


### GetProperty
#### Required Arguments
```dart
String id = ...;
MullakConnector.instance.getProperty(
  id: id,
).execute();
```



#### Return Type
`execute()` returns a `QueryResult<GetPropertyData, GetPropertyVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await MullakConnector.instance.getProperty(
  id: id,
);
GetPropertyData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;

final ref = MullakConnector.instance.getProperty(
  id: id,
).ref();
ref.execute();

ref.subscribe(...);
```


### ListMyChats
#### Required Arguments
```dart
// No required arguments
MullakConnector.instance.listMyChats().execute();
```



#### Return Type
`execute()` returns a `QueryResult<ListMyChatsData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await MullakConnector.instance.listMyChats();
ListMyChatsData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = MullakConnector.instance.listMyChats().ref();
ref.execute();

ref.subscribe(...);
```


### ListMessages
#### Required Arguments
```dart
String chatId = ...;
MullakConnector.instance.listMessages(
  chatId: chatId,
).execute();
```



#### Return Type
`execute()` returns a `QueryResult<ListMessagesData, ListMessagesVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await MullakConnector.instance.listMessages(
  chatId: chatId,
);
ListMessagesData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String chatId = ...;

final ref = MullakConnector.instance.listMessages(
  chatId: chatId,
).ref();
ref.execute();

ref.subscribe(...);
```

## Mutations

### UpsertUser
#### Required Arguments
```dart
String fullName = ...;
String phoneNumber = ...;
bool bOwnerFlag = ...;
bool pOwnerFlag = ...;
MullakConnector.instance.upsertUser(
  fullName: fullName,
  phoneNumber: phoneNumber,
  bOwnerFlag: bOwnerFlag,
  pOwnerFlag: pOwnerFlag,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<UpsertUserData, UpsertUserVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await MullakConnector.instance.upsertUser(
  fullName: fullName,
  phoneNumber: phoneNumber,
  bOwnerFlag: bOwnerFlag,
  pOwnerFlag: pOwnerFlag,
);
UpsertUserData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String fullName = ...;
String phoneNumber = ...;
bool bOwnerFlag = ...;
bool pOwnerFlag = ...;

final ref = MullakConnector.instance.upsertUser(
  fullName: fullName,
  phoneNumber: phoneNumber,
  bOwnerFlag: bOwnerFlag,
  pOwnerFlag: pOwnerFlag,
).ref();
ref.execute();
```


### UpdateMyName
#### Required Arguments
```dart
String fullName = ...;
MullakConnector.instance.updateMyName(
  fullName: fullName,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<UpdateMyNameData, UpdateMyNameVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await MullakConnector.instance.updateMyName(
  fullName: fullName,
);
UpdateMyNameData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String fullName = ...;

final ref = MullakConnector.instance.updateMyName(
  fullName: fullName,
).ref();
ref.execute();
```


### CreateReport
#### Required Arguments
```dart
String description = ...;
String reportType = ...;
MullakConnector.instance.createReport(
  description: description,
  reportType: reportType,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<CreateReportData, CreateReportVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await MullakConnector.instance.createReport(
  description: description,
  reportType: reportType,
);
CreateReportData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String description = ...;
String reportType = ...;

final ref = MullakConnector.instance.createReport(
  description: description,
  reportType: reportType,
).ref();
ref.execute();
```


### CreateReview
#### Required Arguments
```dart
int rating = ...;
MullakConnector.instance.createReview(
  rating: rating,
).execute();
```

#### Optional Arguments
We return a builder for each query. For CreateReview, we created `CreateReviewBuilder`. For queries and mutations with optional parameters, we return a builder class.
The builder pattern allows Data Connect to distinguish between fields that haven't been set and fields that have been set to null. A field can be set by calling its respective setter method like below:
```dart
class CreateReviewVariablesBuilder {
  ...
   CreateReviewVariablesBuilder comment(String? t) {
   _comment.value = t;
   return this;
  }

  ...
}
MullakConnector.instance.createReview(
  rating: rating,
)
.comment(comment)
.execute();
```

#### Return Type
`execute()` returns a `OperationResult<CreateReviewData, CreateReviewVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await MullakConnector.instance.createReview(
  rating: rating,
);
CreateReviewData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
int rating = ...;

final ref = MullakConnector.instance.createReview(
  rating: rating,
).ref();
ref.execute();
```


### CreateProperty
#### Required Arguments
```dart
String title = ...;
String district = ...;
String city = ...;
String propertyType = ...;
double areaSqm = ...;
double rentPrice = ...;
double latitude = ...;
double longitude = ...;
MullakConnector.instance.createProperty(
  title: title,
  district: district,
  city: city,
  propertyType: propertyType,
  areaSqm: areaSqm,
  rentPrice: rentPrice,
  latitude: latitude,
  longitude: longitude,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<CreatePropertyData, CreatePropertyVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await MullakConnector.instance.createProperty(
  title: title,
  district: district,
  city: city,
  propertyType: propertyType,
  areaSqm: areaSqm,
  rentPrice: rentPrice,
  latitude: latitude,
  longitude: longitude,
);
CreatePropertyData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String title = ...;
String district = ...;
String city = ...;
String propertyType = ...;
double areaSqm = ...;
double rentPrice = ...;
double latitude = ...;
double longitude = ...;

final ref = MullakConnector.instance.createProperty(
  title: title,
  district: district,
  city: city,
  propertyType: propertyType,
  areaSqm: areaSqm,
  rentPrice: rentPrice,
  latitude: latitude,
  longitude: longitude,
).ref();
ref.execute();
```


### UpdateMyPropertyStatus
#### Required Arguments
```dart
String id = ...;
String status = ...;
MullakConnector.instance.updateMyPropertyStatus(
  id: id,
  status: status,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<UpdateMyPropertyStatusData, UpdateMyPropertyStatusVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await MullakConnector.instance.updateMyPropertyStatus(
  id: id,
  status: status,
);
UpdateMyPropertyStatusData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;
String status = ...;

final ref = MullakConnector.instance.updateMyPropertyStatus(
  id: id,
  status: status,
).ref();
ref.execute();
```


### AddPropertyImage
#### Required Arguments
```dart
String propertyId = ...;
String imageUrl = ...;
int displayOrder = ...;
MullakConnector.instance.addPropertyImage(
  propertyId: propertyId,
  imageUrl: imageUrl,
  displayOrder: displayOrder,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<AddPropertyImageData, AddPropertyImageVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await MullakConnector.instance.addPropertyImage(
  propertyId: propertyId,
  imageUrl: imageUrl,
  displayOrder: displayOrder,
);
AddPropertyImageData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String propertyId = ...;
String imageUrl = ...;
int displayOrder = ...;

final ref = MullakConnector.instance.addPropertyImage(
  propertyId: propertyId,
  imageUrl: imageUrl,
  displayOrder: displayOrder,
).ref();
ref.execute();
```


### StartChat
#### Required Arguments
```dart
String propertyOwnerId = ...;
MullakConnector.instance.startChat(
  propertyOwnerId: propertyOwnerId,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<StartChatData, StartChatVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await MullakConnector.instance.startChat(
  propertyOwnerId: propertyOwnerId,
);
StartChatData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String propertyOwnerId = ...;

final ref = MullakConnector.instance.startChat(
  propertyOwnerId: propertyOwnerId,
).ref();
ref.execute();
```


### SendMessage
#### Required Arguments
```dart
String chatId = ...;
String content = ...;
MullakConnector.instance.sendMessage(
  chatId: chatId,
  content: content,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<SendMessageData, SendMessageVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await MullakConnector.instance.sendMessage(
  chatId: chatId,
  content: content,
);
SendMessageData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String chatId = ...;
String content = ...;

final ref = MullakConnector.instance.sendMessage(
  chatId: chatId,
  content: content,
).ref();
ref.execute();
```

