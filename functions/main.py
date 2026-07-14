# Welcome to Cloud Functions for Firebase for Python!
# To get started, simply uncomment the below code or create your own.
# Deploy with `firebase deploy`

import logging

from firebase_functions import https_fn
from firebase_functions.options import set_global_options
from firebase_admin import initialize_app

logger = logging.getLogger(__name__)

# For cost control, you can set the maximum number of containers that can be
# running at the same time. This helps mitigate the impact of unexpected
# traffic spikes by instead downgrading performance. This limit is a per-function
# limit. You can override the limit for each function using the max_instances
# parameter in the decorator, e.g. @https_fn.on_request(max_instances=5).
set_global_options(max_instances=10)

# initialize_app()
#
#
# @https_fn.on_request()
# def on_request_example(req: https_fn.Request) -> https_fn.Response:
#     return https_fn.Response("Hello world!")
import firebase_admin
from firebase_admin import auth
from firebase_functions import firestore_fn

# Initialize the Admin SDK
firebase_admin.initialize_app()

# Change "us-east1" to "us-east4" if your database location is Northern Virginia
@firestore_fn.on_document_written(
    document="Users/{uid}",
    region="us-east1"
)
def sync_admin_status(event: firestore_fn.Event[firestore_fn.Change[firestore_fn.DocumentSnapshot | None]]) -> None:
    """Listens to creation or changes in the Users collection to sync claims."""
    
    user_uid = event.params["uid"]
    new_snapshot = event.data.after
    
    if not new_snapshot or not new_snapshot.exists:
        print(f"Document for user {user_uid} was deleted.")
        return

    user_data = new_snapshot.to_dict()
    user_type = user_data.get("type")

    try:
        if user_type == "admin":
            auth.set_custom_user_claims(user_uid, {"admin": True})
            print(f"Successfully granted Admin Auth Claims to UID: {user_uid}")
        else:
            auth.set_custom_user_claims(user_uid, {"admin": False})
            print(f"Successfully stripped Admin Auth Claims from UID: {user_uid}")
            
    except Exception as e:
        print(f"Failed to apply custom user claims for UID {user_uid}. Error: {e}")


import firebase_admin
from firebase_admin import auth, firestore
from firebase_functions import https_fn

# Initialize app if not already initialized by your other trigger functions
if not firebase_admin._apps:
    firebase_admin.initialize_app()

@https_fn.on_call(region="us-east1")
def delete_users_by_yog_callable(req: https_fn.CallableRequest) -> dict:
    """Allows authenticated admins to delete all users matching a specific YOG."""
    
    # 1. Security Check: Verify the request comes from an authenticated user
    if not req.auth:
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.UNAUTHENTICATED,
            message="The function must be called while authenticated."
        )

    # 2. Security Check: Verify the user has administrative privileges
    is_admin = req.auth.token.get("admin", False)
    if not is_admin:
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.PERMISSION_DENIED,
            message="Only system administrators can execute this action."
        )

    # 3. Extract the target YOG year passed from the Flutter app
    raw_target_yog = req.data.get("yearOfGraduation", req.data.get("yog"))
    target_yog = raw_target_yog
    if not target_yog:
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.INVALID_ARGUMENT,
            message="You must supply a valid YOG year parameter."
        )

    try:
        target_yog = int(target_yog)
    except (TypeError, ValueError) as exc:
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.INVALID_ARGUMENT,
            message="The YOG must be an integer year."
        ) from exc

    try:
        db = firestore.client()

        # 4. Query all user documents matching the graduation year
        users_ref = db.collection("Users").where("yearOfGraduation", "==", str(target_yog)).stream()
        uids_to_delete = [doc.id for doc in users_ref]

        if not uids_to_delete:
            return {"success": True, "count": 0, "message": f"No users found matching YOG {target_yog}."}

        # 5. Clean wipe from Firebase Authentication (Processes in chunk blocks up to 1000 users)
        chunks = [uids_to_delete[i:i + 1000] for i in range(0, len(uids_to_delete), 1000)]
        for chunk in chunks:
            auth.delete_users(chunk)

        # 6. Clean wipe from Cloud Firestore Documents using write batches
        batch = db.batch()
        for uid in uids_to_delete:
            doc_ref = db.collection("Users").document(uid)
            batch.delete(doc_ref)
        batch.commit()

        return {
            "success": True,
            "count": len(uids_to_delete),
            "message": f"Successfully wiped {len(uids_to_delete)} users matching YOG {target_yog} across Auth and Firestore."
        }
    except Exception as exc:
        logger.exception("delete_users_by_yog_callable failed")
        print(f"delete_users_by_yog_callable failed: {exc}")
        raise https_fn.HttpsError(
            code=https_fn.FunctionsErrorCode.INTERNAL,
            message=f"Failed to wipe users: {exc}"
        ) from exc
