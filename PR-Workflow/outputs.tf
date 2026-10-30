output "website_url" {
  description = "Public URL of Nurudeen's website"
  value       = "http://${aws_eip.website.public_ip}"
}

output "website_public_ip" {
  description = "Stable Elastic IP address of the website"
  value       = aws_eip.website.public_ip
}

output "middle_tier_private_ip" {
  description = "Private IP address of the middle-tier instance"
  value       = module.middle_tier.private_ip
}
