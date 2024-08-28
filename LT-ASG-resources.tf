resource "aws_launch_template" "web-lt" {
  name          = "web-lt"
  description   = "web-lt "
  image_id      = "ami-02b49a24cfb95941c"
  key_name      = "mumbaiKP"
  instance_type = "t2.micro"

  user_data = base64encode(<<-EOF
    #!/bin/bash
                    sudo yum install httpd -y
                    sudo systemctl start httpd
                    sudo systemctl enable httpd
                    echo "hello world form $(hostname)" > /var/www/html/index.html

  EOF
  )
  # user_data = base64encode(templatefile("${path.module}/userdata.sh", {}))
  network_interfaces {
    security_groups             = [aws_security_group.web-sg.id]
    associate_public_ip_address = true
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 8
      volume_type = "gp3"
      iops        = 3000
    }

  }
}


resource "aws_autoscaling_group" "web-asg" {
  desired_capacity    = 2
  min_size            = 1
  max_size            = 5
  vpc_zone_identifier = [aws_subnet.private-sn-1a.id, aws_subnet.private-sn-1b.id]
  launch_template {
    id      = aws_launch_template.web-lt.id
    version = "$Latest"
  }

  health_check_grace_period = 30
  target_group_arns = [ aws_lb_target_group.web-tg.arn ]

}

resource "aws_autoscaling_notification" "web-asg-notify" {
  group_names = [
    aws_autoscaling_group.web-asg.name
  ]
  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
  ]
  topic_arn = aws_sns_topic.web-top.arn
  
}

resource "aws_sns_topic" "web-top" {
  name = "web-top"
}
