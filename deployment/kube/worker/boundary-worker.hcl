disable_mlock = true

log_level = "debug"

worker {
	name = "local-worker"
	description = "A Local worker for a kubernetes demo"
	address = "localhost"
    controllers = ["cluster.boundary-example.com:30001"]
	public_addr = "localhost"
}

listener "tcp" {
	address = "0.0.0.0"
	purpose = "proxy"
}

kms "aead" {
	purpose = "root"
	aead_type = "aes-gcm"
	key = "sP1fnF5Xz85RrXyELHFeZg9Ad2qt4Z4bgNHVGtD6ung="
	key_id = "global_root"
}

kms "aead" {
	purpose = "worker-auth"
	aead_type = "aes-gcm"
	key = "8fZBjCUfN0TzjEGLQldGY4+iE9AkOvCfjh7+p0GtRBQ="
	key_id = "global_worker-auth"
}

kms "aead" {
	purpose = "recovery"
	aead_type = "aes-gcm"
	key = "8fZBjCUfN0TzjEGLQldGY4+iE9AkOvCfjh7+p0GtRBQ="
	key_id = "global_recovery"
}