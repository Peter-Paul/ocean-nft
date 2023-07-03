const chai = require("chai");
// const { solidity } = require("ethereum-waffle");

const { ethers } = require("hardhat");
const { expect } = chai
// chai.use(solidity);

describe('Neptune Garden contracts', () => {
    let NeptuneGarden, NeptuneAccountRegistry, NeptuneImplementation, neptuneGarden,neptuneAccountRegistry,neptuneImplementation, 
    owner, addr1, addr2

    beforeEach(async () => {
        [owner, addr1, addr2] = await ethers.getSigners();
        NeptuneGarden = await ethers.getContractFactory('NeptuneGarden');
        NeptuneAccountRegistry = await ethers.getContractFactory('NeptuneAccountRegistry')
        NeptuneImplementation = await ethers.getContractFactory('NeptuneImplementation')
        neptuneImplementation = await NeptuneImplementation.deploy();
        const implementationAddress = await neptuneImplementation.getAddress()
        neptuneAccountRegistry = await NeptuneAccountRegistry.deploy(implementationAddress);
        const registryAddress = await neptuneAccountRegistry.getAddress()
        neptuneGarden = await NeptuneGarden.deploy(registryAddress);        
    })


    describe('Minting NFTs', () => {
        it('Should mint free NFT for owner', async () => {
            const sampleUri = ""
            const ownerAddress = owner.address            
            await neptuneGarden
                    .connect(owner).safeMint(
                        ownerAddress,
                        sampleUri
                    );

            const ownerBalance = await neptuneGarden.balanceOf(ownerAddress);
            expect(parseInt(ownerBalance)).to.equal(1);
        })


        it('Should revert if more than one mint has no MINT_PRICE', async () => {
            const sampleUri = ""
            const ownerAddress = owner.address            
            await neptuneGarden
                    .connect(owner).safeMint(
                        ownerAddress,
                        sampleUri
                    );
            await expect(neptuneGarden
                    .connect(owner).safeMint(
                        ownerAddress,
                        sampleUri
                    )).to.be.revertedWith("Sorry, amount less than mint price!");

        })

        it('Should revert if more than one mint has less MINT_PRICE', async () => {
            const mintPrice = ethers.parseEther("0.01")
            const sampleUri = ""
            const ownerAddress = owner.address            
            await neptuneGarden
                    .connect(owner).safeMint(
                        ownerAddress,
                        sampleUri
                    );
            await expect(neptuneGarden
                    .connect(owner).safeMint(
                        ownerAddress,
                        sampleUri,
                        {value:mintPrice}
                    )).to.be.revertedWith("Sorry, amount less than mint price!");

        })


        it('Should mint 2nd token with MINT_PRICE', async () => {
            const mintPrice = ethers.parseEther("0.05")
            const sampleUri = ""
            const ownerAddress = owner.address            
            await neptuneGarden
                    .connect(owner).safeMint(
                        ownerAddress,
                        sampleUri
                    );
            await neptuneGarden
                    .connect(owner).safeMint(
                        ownerAddress,
                        sampleUri,
                        {value:mintPrice}
                    )
            
            const ownerBalance = await neptuneGarden.balanceOf(ownerAddress);
            expect(parseInt(ownerBalance)).to.equal(2);
        })


        it('Should revert if minted more than 3 NFTs', async () => {
            const mintPrice = ethers.parseEther("0.05")
            const sampleUri = ""
            const ownerAddress = owner.address            
            await neptuneGarden
                    .connect(owner).safeMint(
                        ownerAddress,
                        sampleUri
                    );

            await neptuneGarden
                    .connect(owner).safeMint(
                        ownerAddress,
                        sampleUri,
                        {value:mintPrice}
                    )

            await neptuneGarden
                .connect(owner).safeMint(
                    ownerAddress,
                    sampleUri,
                    {value:mintPrice}
                )
            
            await expect(neptuneGarden
                    .connect(owner).safeMint(
                        ownerAddress,
                        sampleUri,
                        {value:mintPrice}
                    )).to.be.revertedWith("Sorry, mint limit for wallet reached!");

        })

    });
})