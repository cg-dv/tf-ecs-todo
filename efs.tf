resource "aws_efs_file_system" "todo-efs" {
  creation_token   = "todo-efs"
  encrypted        = false
  throughput_mode  = "bursting"
  performance_mode = "generalPurpose"
}

resource "aws_efs_mount_target" "mount-target" {
  file_system_id  = aws_efs_file_system.todo-efs.id
  subnet_id       = aws_subnet.private_subnet_1.id
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_access_point" "access_point" {
  file_system_id = aws_efs_file_system.todo-efs.id
  posix_user {
    gid = 1000
    uid = 1000
  }
  root_directory {
    path = "/var/lib/mysql"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "755"
    }
  }
}
