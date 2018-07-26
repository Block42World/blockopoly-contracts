const { assertRevert } = require('openzeppelin-solidity/test/helpers/assertRevert')

const BigNumber = web3.BigNumber
const World = artifacts.require('World')

require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should()

contract('World', (accounts) => {
  const worldName = 'Block42 World'
  const worldSymbol = 'B42WD'
  const firstTokenId = 0
  const secondTokenId = 1
  const unknownTokenId = 2
  const creator = accounts[0]
  const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000'

  beforeEach(async () => {
    this.world = await World.new(worldName, worldSymbol, { from: creator })
    await this.world.create(firstTokenId, { from: creator })
  })

  describe('create', () => {
    const tokenId = unknownTokenId
    let logs = null

    describe('when successful', () => {
      beforeEach(async () => {
        const result = await this.world.create(tokenId)
        logs = result.logs
      })

      it('assigns the token to creator', async () => {
        const owner = await this.world.ownerOf(tokenId)
        owner.should.be.equal(creator)
      })

      it('increases the balance of its owner', async () => {
        const balance = await this.world.balanceOf(creator)
        balance.should.be.bignumber.equal(2)
      })

      it('emits a transfer event', async () => {
        logs.length.should.be.equal(1)
        logs[0].event.should.be.eq('Transfer')
        logs[0].args._from.should.be.equal(ZERO_ADDRESS)
        logs[0].args._to.should.be.equal(creator)
        logs[0].args._tokenId.should.be.bignumber.equal(tokenId)
      })
    })

    describe('when the given token ID was already tracked by this contract', () => {
      it('reverts', async () => {
        await assertRevert(this.world.create(firstTokenId))
      })
    })
  })

  describe('createAndTransfer', () => {
    const to = accounts[1]
    const tokenId = secondTokenId
    let logs = null

    describe('when successful', () => {
      beforeEach(async () => {
        const result = await this.world.createAndTransfer(to, tokenId)
        logs = result.logs
      })

      it('assigns the token to the new owner', async () => {
        const owner = await this.world.ownerOf(tokenId)
        owner.should.be.equal(to)
      })

      it('increases the balance of its owner', async () => {
        const balance = await this.world.balanceOf(to)
        balance.should.be.bignumber.equal(1)
      })

      it('emits a transfer event', async () => {
        logs.length.should.be.equal(1)
        logs[0].event.should.be.eq('Transfer')
        logs[0].args._from.should.be.equal(ZERO_ADDRESS)
        logs[0].args._to.should.be.equal(to)
        logs[0].args._tokenId.should.be.bignumber.equal(tokenId)
      })
    })

    describe('when the given token ID was already tracked by this contract', () => {
      it('reverts', async () => {
        await assertRevert(this.world.createAndTransfer(to, firstTokenId))
      })
    })

    it('transfered to others', async () => {
      await this.world.createAndTransfer(to, tokenId, { from: creator })
      const owner = await this.world.ownerOf(tokenId)
      owner.should.be.equal(to)
    })
  })

  describe('expropriateToken', () => {
    const worldOwner = accounts[1]
    const tokenId = secondTokenId

    it('should prevent non-creator from expropriating token', async () => {
      await this.world.createAndTransfer(worldOwner, tokenId)
      creator.should.not.eq(worldOwner)
      await assertRevert(this.world.expropriate(tokenId, { from: worldOwner }))
      const other = accounts[2]
      creator.should.not.eq(other)
      await assertRevert(this.world.expropriate(tokenId, { from: other }))
    })
  })
})
