# Aistor
aistor is a service that runs inside Docker containers. 

---

## Step 1: Create the New Bucket

1. Log in to the Object Storage Web Console.
2. Click **Create Bucket** (or the **`+`** icon).
3. Enter your **Bucket Name** and click **Save / Create**.

---

## Step 2: Grant User Access to the New Bucket

Because user access is restricted per bucket, you must explicitly attach the new bucket's name to the user's access keys:

1. In the navigation menu, go to **Users**.
2. Click on the target user: **`myapp-admin`**.
3. Go to the **Access Keys** tab.
4. Click **Edit** on the existing Access Key.
5. Add the name of your **new bucket** to the allowed resource list / policy.
6. Save the changes.

---

## Step 3: Configure Anonymous Access Rules

To set up direct public access rules on the new bucket:

1. Go back to **Buckets** and click into your **newly created bucket**.
2. Scroll down and locate the **Anonymous Access** section.
3. Click **Add Access Rule**.
4. Configure the rule:
   * **Prefix:** Enter `/`
   * **Access:** Select **`readwrite`**
5. Click **Save**.

---

### Quick Summary Workflow

```
[ Create Bucket ] ➔ [ Users ➔ wetvpro-admin ➔ Edit Access Key ➔ Add New Bucket Name ] ➔ [ New Bucket ➔ Anonymous Access ➔ Add Access Rule ➔ Prefix: '/' ➔ Access: readwrite ]
```

