import smtplib
import pandas as pd
import json
import sys
import platform

# Ensure we are using the correct Python version
expected_version = "3.13.2"
if platform.python_version() != expected_version:
    print(f"Warning: Running on Python {platform.python_version()}, expected {expected_version}")

# Splunk alert script gets data from STDIN
alert_data = sys.stdin.read()

# Parse the incoming alert data from Splunk
events = [json.loads(line) for line in alert_data.split("\n") if line]

# Convert data to Pandas DataFrame
df = pd.DataFrame(events)

# Generate Summary
summary = {
    "Total Events": len(df),
    "Most Common Event Codes": df["EventCode"].value_counts().head(5).to_dict(),
    "Most Frequent Sources": df["SourceName"].value_counts().head(5).to_dict(),
}

# Include messages corresponding to the top 5 most common event codes
event_messages = {}

if "EventCode" in df.columns and "Message" in df.columns:
    top_events = df["EventCode"].value_counts().head(5).index  # Get top 5 EventCodes

    for event_code in top_events:
        messages = df[df["EventCode"] == event_code]["Message"].dropna().unique()[:3]  # Get up to 3 unique messages
        event_messages[str(event_code)] = list(messages)

summary["Event Messages"] = event_messages

# Convert Summary to JSON
summary_text = json.dumps(summary, indent=4)

# Email Configuration
SMTP_SERVER = "smtp.gmail.com"
SMTP_PORT = 587
EMAIL_SENDER = ""
EMAIL_PASSWORD = ""
EMAIL_RECEIVER = ""
SUBJECT = "Splunk Windows Logs Summary Alert"

# Email Body
email_body = f"Subject: {SUBJECT}\n\n{summary_text}"

# Send Email
try:
    server = smtplib.SMTP(SMTP_SERVER, SMTP_PORT)
    server.starttls()
    server.login(EMAIL_SENDER, EMAIL_PASSWORD)
    server.sendmail(EMAIL_SENDER, EMAIL_RECEIVER, email_body)
    server.quit()
    print("Summary email sent successfully.")
except Exception as e:
    print(f"Failed to send email: {e}")
