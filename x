package BLC

import (
	"bytes"
	"crypto/sha256"
	"fmt"
	"math/big"
)

//256位hash里面至少要有16个0



const targetBit  = 16



type ProofOfWork struct {
	Block *Block //当前要验证的区块
	target *big.Int // 大数据存储
}

//数据拼接，返回字节数组
func (pow *ProofOfWork) prepareData(nonce int) []byte{
	data := bytes.Join(
		[][]byte{
			pow.Block.PrevBlockHash,
			pow.Block.Data,
			IntToHex(pow.Block.Timestamp),
			IntToHex(int64(targetBit)),
			IntToHex(int64(nonce)),
			IntToHex(int64(pow.Block.Hight)),
		},
		[]byte{},
		)

	return data
}


func (proofOfWork *ProofOfWork) IsValid() bool {





	//
	var hashInt big.Int
	hashInt.SetBytes(proofOfWork.Block.Hash)
	// Cmp compares x and y and returns:
	//
	//   -1 if x <  y
	//    0 if x == y
	//   +1 if x >  y


	if proofOfWork.target.Cmp(&hashInt) == 1{
		return true
	}

	return false
}


func (ProofOfWork *ProofOfWork) Run() ([]byte,int64){

	// 1. 将Block的属性拼接成字节数组

	// 2. 生成hash

	// 3. 判断hash有效性，如果满足条件，跳出循环


	nonce := 0

	var hashInt big.Int //用来存储我们新生成的hash值
	var hash [32]byte

	for{

		dataBytes := ProofOfWork.prepareData(nonce)


		hash := sha256.Sum256(dataBytes)
		fmt.Printf("\r%x",hash)



		hashInt.SetBytes(hash[:])

		//判断hashint是否小于Block里面的target
		// Cmp compares x and y and returns:
		//
		//   -1 if x <  y
		//    0 if x == y
		//   +1 if x >  y

		if ProofOfWork.target.Cmp(&hashInt) == 1{
			break
		}

		nonce = nonce + 1
	}

	return hash[:],int64(nonce)
}

//创建新的工作量证明对象
func NewProofOfWork(block *Block) *ProofOfWork{
	//1. big.Int对象 值为1
	//   2
	// 0000 0001
	// 8 - 2 = 6
	// 0100 0000 = 64
	// 0010 0000 = 32
	// 判断0的个数可以通过 数的大小进行判断




	// 1. 创建一个初始值为1的target
	target := big.NewInt(1)
	// 2. 左移 256 - targetbit


	target = target.Lsh(target , 256 - targetBit)

	return &ProofOfWork{block,target}
}


