<?php
include_once("dbconnect.php");
//payment_update.php
// Enable error reporting for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Fetch and validate required parameters
$userid = isset($_GET['userid']) ? $_GET['userid'] : null;
$email = isset($_GET['email']) ? $_GET['email'] : null;
$phone = isset($_GET['phone']) ? $_GET['phone'] : null;
$name = isset($_GET['name']) ? $_GET['name'] : null;
$amount = isset($_GET['amount']) ? $_GET['amount'] : null;
$checkout_type = isset($_GET['checkout_type']) ? $_GET['checkout_type'] : null;

// Additional inputs based on checkout type
$membershipid = null;
$selectedItems = [];
if ($checkout_type === 'product') {
    $selectedItems = json_decode($_GET['selected_items'], true);
    if (!$selectedItems) {
        die("Missing selected items for product checkout.");
    }
} elseif ($checkout_type === 'membership') {
    $membershipid = isset($_GET['membershipid']) ? $_GET['membershipid'] : null;
    if (!$membershipid) {
        die("Missing membership ID for membership checkout.");
    }
} else {
    die("Invalid checkout type.");
}

// Fetch Billplz parameters
$billplz_id = isset($_GET['billplz']['id']) ? $_GET['billplz']['id'] : null;
$billplz_paid = isset($_GET['billplz']['paid']) ? $_GET['billplz']['paid'] : null;
$billplz_paid_at = isset($_GET['billplz']['paid_at']) ? $_GET['billplz']['paid_at'] : null;
$billplz_x_signature = isset($_GET['billplz']['x_signature']) ? $_GET['billplz']['x_signature'] : null;

// Validate received parameters
if (!$userid || !$email || !$phone || !$name || !$amount || !$billplz_id || !$billplz_paid) {
    die("Missing required parameters.");
}

// Validate payment status
$paidstatus = $billplz_paid === "true" ? "Success" : "Failed";
$receiptid = $billplz_id;

// Generate signature for validation
$signing = '';
$data = [
    'id' => $billplz_id,
    'paid_at' => $billplz_paid_at,
    'paid' => $billplz_paid
];
foreach ($data as $key => $value) {
    $signing .= 'billplz' . $key . $value;
    if ($key === 'paid') {
        break;
    } else {
        $signing .= '|';
    }
}

// Replace with your Billplz x_signature key
$x_signature_key = '3a2ab6c6ce896a97d6946f643523002c1134099863a568cb4e572b18e153e3054e92256ebed23c8aeece17dc1111de774c744b136297092cef3c3a3db0e1797b';
$signed = hash_hmac('sha256', $signing, $x_signature_key);

// Validate signature
if ($signed === $billplz_x_signature) {
    if ($paidstatus === "Success") {
        // Insert payment record into `tbl_purchases`
        $sqlInsertPurchase = "INSERT INTO tbl_purchases (user_id, payment_amount, payment_status, purchase_date, membership_id) 
                              VALUES ('$userid', '$amount', 'Paid', NOW(), " . ($membershipid ? "'$membershipid'" : "NULL") . ")";
        if (!$conn->query($sqlInsertPurchase)) {
            die("Error inserting purchase record: " . $conn->error);
        }
        $purchaseId = $conn->insert_id; // Get the ID of the inserted purchase

        // Insert selected items if it's a product purchase
        if ($checkout_type === 'product') {
            foreach ($selectedItems as $item) {
                $productId = $item['product_id'];
                $quantity = $item['quantity'];
                $price = $item['price'];
                $sqlInsertItem = "INSERT INTO tbl_selected_items (purchase_id, product_id, quantity, price) 
                                  VALUES ('$purchaseId', '$productId', '$quantity', '$price')";
                if (!$conn->query($sqlInsertItem)) {
                    die("Error inserting selected item: " . $conn->error);
                }
            }
        }
        if ($checkout_type === 'product') {
            foreach ($selectedItems as $item) {
                $productId = $item['product_id'];

                // Correct the SQL syntax for UPDATE
                $sqlUpdateItem = "UPDATE tbl_cart 
                          SET cart_status = 'Paid' 
                          WHERE product_id = $productId";

                if (!$conn->query($sqlUpdateItem)) {
                    die("Error updating cart item: " . $conn->error);
                }
            }
        }


        // Retrieve purchased items for display (for product purchase)
        $purchasedItems = [];
        if ($checkout_type === 'product') {
            $sqlGetItems = "SELECT si.product_id, si.quantity, si.price, p.product_title 
                            FROM tbl_selected_items si
                            JOIN tbl_products p ON si.product_id = p.product_id
                            WHERE si.purchase_id = '$purchaseId'";
            $result = $conn->query($sqlGetItems);
            if ($result && $result->num_rows > 0) {
                while ($row = $result->fetch_assoc()) {
                    $purchasedItems[] = $row;
                }
            }
        }
        // Handle membership purchases
if ($checkout_type === 'membership' && $membershipid) {
    $currentDate = date('Y-m-d');

    // Fetch membership duration
    $sqlGetMembership = "SELECT duration FROM tbl_memberships WHERE membership_id = $membershipid";
    $result = $conn->query($sqlGetMembership);

    if ($result && $result->num_rows > 0) {
        $row = $result->fetch_assoc();
        $duration = $row['duration'];

        $startDate = $currentDate;
        $endDate = date('Y-m-d', strtotime("+$duration days"));

        // Insert membership record
        $sqlInsertMembership = "INSERT INTO tbl_user_membership_status (user_id, membership_id, start_date, end_date, status)
                                 VALUES ('$userid', '$membershipid', '$startDate', '$endDate', 'Active')";
        if (!$conn->query($sqlInsertMembership)) {
            die("Error inserting membership record: " . $conn->error);
        }
    } else {
        die("Error fetching membership duration: " . $conn->error);
    }
}


        // Display success receipt
        echo "
<!DOCTYPE html>
<html lang='en'>
<head>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <link href='https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&display=swap' rel='stylesheet'>
    <style>
        body {
            font-family: 'Roboto', Arial, sans-serif;
            background-color: #f9f9f9;
            margin: 0;
            padding: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100vh;
        }
        .payment-container {
            background: #fff;
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.15);
            max-width: 500px;
            width: 100%;
            text-align: center;
        }
        .logo {
            width: 120px;
            margin: 0 auto 20px;
        }
        h2 {
            color: #333;
            margin-bottom: 20px;
            font-size: 24px;
            font-weight: 700;
        }
        .payment-table, .items-table {
            width: 100%;
            margin-top: 20px;
            border-collapse: collapse;
            text-align: left;
        }
        .payment-table th, .payment-table td,
        .items-table th, .items-table td {
            border: 1px solid #e0e0e0;
            padding: 12px;
            font-size: 14px;
        }
        .payment-table th, .items-table th {
            background-color: #f5f5f5;
            font-weight: 500;
        }
        .items-table td {
            color: #555;
        }
        .items-table tr:last-child td {
            font-weight: bold;
            color: #000;
        }
        .status {
            font-weight: bold;
            font-size: 14px;
        }
        .status-success {
            color: #4caf50;
        }
        .status-failed {
            color: #e53935;
        }
        .back-button {
            background-color: #4caf50;
            color: white;
            padding: 12px 20px;
            text-decoration: none;
            margin-top: 20px;
            border-radius: 8px;
            display: inline-block;
            font-weight: 500;
            transition: background-color 0.3s ease;
        }
        .back-button:hover {
            background-color: #43a047;
        }
    </style>
</head>
<body>
    <div class='payment-container'>
        <img src='https://feeyazproduction.com/simple_app/assets/logo/LogoSimpleApp.png' alt='Company Logo' class='logo'>
        <h2>Payment Receipt</h2>
        <table class='payment-table'>
            <tr><th>Receipt ID</th><td>" . htmlspecialchars($receiptid) . "</td></tr>
            <tr><th>Name</th><td>" . htmlspecialchars($name) . "</td></tr>
            <tr><th>Email</th><td>" . htmlspecialchars($email) . "</td></tr>
            <tr><th>Phone</th><td>" . htmlspecialchars($phone) . "</td></tr>
            <tr><th>Amount Paid</th><td>RM" . htmlspecialchars($amount) . "</td></tr>
            <tr><th>Status</th>
                <td class='status " . ($paidstatus === 'Success' ? 'status-success' : 'status-failed') . "'>
                    " . htmlspecialchars($paidstatus) . "
                </td>
            </tr>
        </table>";

        if ($checkout_type === 'product') {
            echo "
    <h3>Purchased Items</h3>
    <table class='items-table'>
        <tr><th>Product Name</th><th>Quantity</th><th>Price</th></tr>";
            foreach ($purchasedItems as $item) {
                echo "
        <tr>
            <td>" . htmlspecialchars($item['product_title']) . "</td>
            <td>" . htmlspecialchars($item['quantity']) . "</td>
            <td>RM" . htmlspecialchars($item['price']) . "</td>
        </tr>";
            }
            echo "
        <tr>
            <td colspan='2'><strong>Total Price</strong></td>
            <td>RM" . htmlspecialchars($amount) . "</td>
        </tr>
    </table>";
        } elseif ($checkout_type === 'membership') {
            echo "
    <h3>Membership Details</h3>
    <p><strong>Membership ID:</strong> " . htmlspecialchars($membershipid) . "</p>";
        }

        echo "
        <a href='/simple_app/views/membership/membership_page.dart' class='back-button'>Back to Membership</a>
    </div>
</body>
</html>";

    }
    else{
        
            //failed
            echo "
        <!DOCTYPE html>
        <html lang='en'>
        <head>
            <meta name='viewport' content='width=device-width, initial-scale=1'>
            <link href='https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&display=swap' rel='stylesheet'>
            <style>
                body {
                    font-family: 'Roboto', Arial, sans-serif;
                    background-color: #f9f9f9;
                    margin: 0;
                    padding: 0;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    height: 100vh;
                }
                .payment-container {
                    background: #fff;
                    padding: 25px;
                    border-radius: 12px;
                    box-shadow: 0 8px 20px rgba(0, 0, 0, 0.15);
                    max-width: 500px;
                    width: 100%;
                    text-align: center;
                }
                .logo {
                    width: 120px;
                    margin: 0 auto 20px;
                }
                h2 {
                    color: #333;
                    margin-bottom: 20px;
                    font-size: 24px;
                    font-weight: 700;
                }
                .payment-table, .items-table {
                    width: 100%;
                    margin-top: 20px;
                    border-collapse: collapse;
                    text-align: left;
                }
                .payment-table th, .payment-table td,
                .items-table th, .items-table td {
                    border: 1px solid #e0e0e0;
                    padding: 12px;
                    font-size: 14px;
                }
                .payment-table th, .items-table th {
                    background-color: #f5f5f5;
                    font-weight: 500;
                }
                .items-table td {
                    color: #555;
                }
                .items-table tr:last-child td {
                    font-weight: bold;
                    color: #000;
                }
                .status {
                    font-weight: bold;
                    font-size: 14px;
                }
                .status-success {
                    color: #4caf50;
                }
                .status-failed {
                    color: #e53935;
                }
                .back-button {
                    background-color: #4caf50;
                    color: white;
                    padding: 12px 20px;
                    text-decoration: none;
                    margin-top: 20px;
                    border-radius: 8px;
                    display: inline-block;
                    font-weight: 500;
                    transition: background-color 0.3s ease;
                }
                .back-button:hover {
                    background-color: #43a047;
                }
            </style>
        </head>
        <body>
            <div class='payment-container'>
                <img src='https://feeyazproduction.com/simple_app/assets/logo/LogoSimpleApp.png' alt='Company Logo' class='logo'>
                <h2>Payment Receipt</h2>
                <table class='payment-table'>
                    <tr><th>Receipt ID</th><td>" . htmlspecialchars($receiptid) . "</td></tr>
                    <tr><th>Name</th><td>" . htmlspecialchars($name) . "</td></tr>
                    <tr><th>Email</th><td>" . htmlspecialchars($email) . "</td></tr>
                    <tr><th>Phone</th><td>" . htmlspecialchars($phone) . "</td></tr>
                    <tr><th>Amount Paid</th><td>RM" . htmlspecialchars($amount) . "</td></tr>
                    <tr><th>Status</th>
                        <td class='status " . ($paidstatus === 'Success' ? 'status-success' : 'status-failed') . "'>
                            " . htmlspecialchars($paidstatus) . "
                        </td>
                    </tr>
                </table>";
        
            if ($checkout_type === 'product') {
                echo "
            <h3>Purchased Items</h3>
            <table class='items-table'>
                <tr><th>Product Name</th><th>Quantity</th><th>Price</th></tr>";
                foreach ($purchasedItems as $item) {
                    echo "
                <tr>
                    <td>" . htmlspecialchars($item['product_title']) . "</td>
                    <td>" . htmlspecialchars($item['quantity']) . "</td>
                    <td>RM" . htmlspecialchars($item['price']) . "</td>
                </tr>";
                }
                echo "
                <tr>
                    <td colspan='2'><strong>Total Price</strong></td>
                    <td>RM" . htmlspecialchars($amount) . "</td>
                </tr>
            </table>";
            } elseif ($checkout_type === 'membership') {
                echo "
            <h3>Membership Details</h3>
            <p><strong>Membership ID:</strong> " . htmlspecialchars($membershipid) . "</p>";
            }
        
            echo "
                <a href='/simple_app/views/membership/membership_page.dart' class='back-button'>Back to Membership</a>
            </div>
        </body>
        </html>";
    }
} else {
    echo "Invalid signature.";
}

?>