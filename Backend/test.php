<?php
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

require 'PHPMailer/src/Exception.php';
require 'PHPMailer/src/PHPMailer.php';
require 'PHPMailer/src/SMTP.php';

$mail = new PHPMailer(true);

try {
    $mail->isSMTP();
    $mail->Host       = 'smtp.gmail.com';
    $mail->SMTPAuth   = true;
    $mail->Username   = 'maanojpalani@gmail.com'; 
    $mail->Password   = 'ohwrfelrljmvjlni'; // App Password
    $mail->SMTPSecure = 'ssl';
    $mail->Port = 465;


    $mail->setFrom('maanojpalani@gmail.com', 'Bus Echo');
    $mail->addAddress('maanojp4285.sse@saveetha.com');
    $mail->Subject = 'Test Email';
    $mail->Body    = 'This is a test email sent using PHPMailer.';

    if ($mail->send()) {
        echo "✅ Test email sent successfully!";
    }
} catch (Exception $e) {
    echo "❌ Mailer Error: {$mail->ErrorInfo}";
}
?>
