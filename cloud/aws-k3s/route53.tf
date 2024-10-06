# Data source to retrieve the route53 hosted zone
data "aws_route53_zone" "main" {
  name         = "aws.your-domain.com"
  private_zone = false
}

# Create CNAME record
resource "aws_route53_record" "k3s" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "k3s.aws.your-domain.com"
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.nlb_main.dns_name] 
}