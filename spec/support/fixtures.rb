def fixtures_file(relative_path)
  dir = Dir["./spec/fixtures"]
  File.read File.join(dir, relative_path)
end

def fake_hash
  SecureRandom.hex(16)
end

def testnet_address(pubkey = SecureRandom.hex(20))
  pubkey = Bitcoin.hash160(pubkey)
  Bitcoin.hash160_to_address pubkey
end
