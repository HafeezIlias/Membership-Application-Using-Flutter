<?php
// Enable error reporting during development
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Fetch and validate inputs
$userid = $_GET['userid'] ?? null;
$email = $_GET['email'] ?? null;
$phone = $_GET['phone'] ?? null;
$name = $_GET['name'] ?? null;
$amount = $_GET['amount'] ?? null;
$checkout_type = $_GET['checkout_type'] ?? null;

// Validate required inputs
if (!$userid || !$email || !$phone || !$name || !$amount || !$checkout_type) {
    die("Invalid input.");
}

// Handle specific inputs based on checkout type
$additional_description = '';
if ($checkout_type === 'product') {
    // Retrieve and decode selected items
    $selected_items = $_GET['selected_items'] ?? null; // JSON string expected
    if (!$selected_items) {
        die("No selected items provided.");
    }

    // Decode and validate JSON structure
    $selected_items_array = json_decode($selected_items, true);
    if (json_last_error() !== JSON_ERROR_NONE) {
        die("Invalid JSON format for selected items.");
    }

    // Display the selected items
    echo "<h3>Selected Items</h3>";
    echo "<table border='1' cellpadding='10'>";
    echo "<tr><th>Product ID</th><th>Product Name</th><th>Quantity</th><th>Price (RM)</th></tr>";

    foreach ($selected_items_array as $item) {
        // Ensure each item has the required fields
        if (!isset($item['product_id'], $item['product_name'], $item['quantity'], $item['price'])) {
            die("Invalid item structure.");
        }

        // Display item details
        echo "<tr>\n";
        echo "    <td>" . htmlspecialchars($item['product_id']) . "</td>\n";
        echo "    <td>" . htmlspecialchars($item['product_name']) . "</td>\n";
        echo "    <td>" . htmlspecialchars($item['quantity']) . "</td>\n";
        echo "    <td>" . htmlspecialchars($item['price']) . "</td>\n";
        echo "</tr>";
    }
    echo "</table>";

    $additional_description = 'Products: ' . $selected_items;
} elseif ($checkout_type === 'membership') {
    // Retrieve and validate membership_id
    $membershipid = $_GET['membership_id'] ?? null;
    if (!$membershipid || !is_numeric($membershipid)) {
        die("Invalid input for membership ID.");
    }
    $additional_description = 'Membership ID: ' . $membershipid;
} else {
    die("Invalid checkout type.");
}

// Billplz API setup
$api_key = '90917da0-ea40-4739-830a-7d2bf27c8af3'; // Secure this in production
$collection_id = 'sxgm4jek';
$host = 'https://www.billplz-sandbox.com/api/v3/bills';

$data = [
    'collection_id' => $collection_id,
    'email' => $email,
    'mobile' => $phone,
    'name' => $name,
    'amount' => $amount * 100, // Convert to cents
    'description' => 'Payment for order by ' . $name . ' (' . $checkout_type . ')',
    'callback_url' => "https://feeyazproduction.com/return_url",
    'redirect_url' => "https://feeyazproduction.com/simple_app/api/payment_update.php?" . http_build_query([
        'userid' => $userid,
        'email' => $email,
        'phone' => $phone,
        'amount' => $amount,
        'name' => $name,
        'checkout_type' => $checkout_type,
        'selected_items' => $checkout_type === 'product' ? $selected_items : null,
        'membershipid' => $checkout_type === 'membership' ? $membershipid : null
    ])
];

// Send request to Billplz API
$process = curl_init($host);
curl_setopt($process, CURLOPT_HEADER, 0);
curl_setopt($process, CURLOPT_USERPWD, $api_key . ":");
curl_setopt($process, CURLOPT_TIMEOUT, 30);
curl_setopt($process, CURLOPT_RETURNTRANSFER, 1);
curl_setopt($process, CURLOPT_SSL_VERIFYHOST, 0);
curl_setopt($process, CURLOPT_SSL_VERIFYPEER, 0);
curl_setopt($process, CURLOPT_POSTFIELDS, http_build_query($data));

$return = curl_exec($process);
if (curl_errno($process)) {
    die("CURL error: " . curl_error($process));
}
curl_close($process);

// Handle response
$bill = json_decode($return, true);
if (isset($bill['url'])) {
    header("Location: {$bill['url']}");
    exit;
} else {
    echo "Failed to create Billplz bill. Response: " . print_r($bill, true);
}
?>
