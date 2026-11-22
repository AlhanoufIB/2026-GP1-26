# Basic Usage

```dart
MullakConnector.instance.UpsertUser(upsertUserVariables).execute();
MullakConnector.instance.GetMyProfile().execute();
MullakConnector.instance.UpdateMyName(updateMyNameVariables).execute();
MullakConnector.instance.CreateReport(createReportVariables).execute();
MullakConnector.instance.CreateReview(createReviewVariables).execute();
MullakConnector.instance.CreateProperty(createPropertyVariables).execute();
MullakConnector.instance.UpdateMyPropertyStatus(updateMyPropertyStatusVariables).execute();
MullakConnector.instance.AddPropertyImage(addPropertyImageVariables).execute();
MullakConnector.instance.ListAvailableProperties().execute();
MullakConnector.instance.ListMyProperties().execute();

```

## Optional Fields

Some operations may have optional fields. In these cases, the Flutter SDK exposes a builder method, and will have to be set separately.

Optional fields can be discovered based on classes that have `Optional` object types.

This is an example of a mutation with an optional field:

```dart
await MullakConnector.instance.CreateProperty({ ... })
.address(...)
.execute();
```

Note: the above example is a mutation, but the same logic applies to query operations as well. Additionally, `createMovie` is an example, and may not be available to the user.

