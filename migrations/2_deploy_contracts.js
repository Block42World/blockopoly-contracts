const World = artifacts.require('World')
const Land = artifacts.require('Land')

module.exports = (deployer, network, accounts) => {
  return deployer
    .then(() => {
      return deployer.deploy(World, 'Block42 World', 'B42WD')
    })
    .then(() => {
      return deployer.deploy(Land, 'Block42 Land', 'B42LD', World.address)
    })
}
