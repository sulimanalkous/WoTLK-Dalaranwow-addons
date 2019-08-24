-- Huffman decompressor written in Lua
-- coded 2007 by Rene Schneider (Slarti on EU-Blackhand) for MobMap
-- http://www.mobmap.de

-- The corresponding encoder is written in Java
-- Its source can be downloaded from http://www.mobmap.de/files/HuffmanCoder.java


huffman_poweroftwo = {
	[0] = 1,
	[1] = 2,
	[2] = 4,
	[3] = 8,
	[4] = 16,
	[5] = 32,
	[6] = 64,
	[7] = 128,
	[8] = 256,
}

function HuffmanDecode(inputdata, tree, precodingtable)
	--first, check for bit length field
	local bitlength=string.match(inputdata,"^(%d+)|.*");
	local data=string.match(inputdata,"^%d+|(.*)");
	if(bitlength==nil) then
		-- data doesn't seem to be encoded, just return it assuming it's already decoded
		return inputdata;
	end
	bitlength=tonumber(bitlength);

	-- decode the data

	local bitpos=0;
	local symbollen=0;
	local result="";
	while(bitpos<bitlength) do
		for symbollen=1,31,1 do
			-- first check if there are any nodes with this symbol length in the tree; if there are none, we can skip this symbol length
			if(tree[symbollen]~=nil) then
				local startpos=bitpos;
				local endpos=bitpos+(symbollen-1);
				local startbyte=math.floor(startpos/8);
				local endbyte=math.floor(endpos/8);
				local symbol=string.byte(data,startbyte+1);
				local savedsymbol=symbol;
				-- mask out the actual symbol part
				symbol=symbol%huffman_poweroftwo[8-(startpos%8)];
				if(endbyte~=startbyte) then
					local bytediff;
					for bytediff=1,endbyte-startbyte,1 do
						-- symbol continues in one of the next bytes
						local symbolend=string.byte(data,startbyte+bytediff+1);
						-- shift it down to the beginning of the byte
						local bytesToShift;
						if(startbyte+bytediff==endbyte) then
							bytesToShift=(endpos%8);
						else
							bytesToShift=7;
						end
						symbolend=math.floor(symbolend/huffman_poweroftwo[(8-bytesToShift)-1]);
						-- shift the higher symbol part up to make room for the lower part
						symbol=symbol*huffman_poweroftwo[bytesToShift+1];
						-- copy lower part into higher part
						symbol=symbol+symbolend;
					end
				else
					-- shift the symbol down to the beginning of the byte
					symbol=math.floor(symbol/huffman_poweroftwo[(8-(endpos%8))-1]);
				end
				if(tree[symbollen][symbol]~=nil) then
					-- a matching node has been found *cheer* Add its corresponding character to the string, increase bitpos and continue the outer loop.
					result=result..tree[symbollen][symbol];
					bitpos=bitpos+symbollen;
					break;
				end
			else
				if(symbollen==31) then
					-- symbol length 31 should never be reached under normal circumstances -> fatal error!
					DEFAULT_CHAT_FRAME:AddMessage("FATAL ERROR in HuffmanDecode at bitpos "..bitpos);
					return nil;
				end
			end
		end
	end

	-- now undo the precoding, if a precoding table was given
	if(precodingtable) then
		local pos=1;
		repeat
			if(string.byte(result,pos)==31) then
				local replacementIndex=string.byte(result,pos+1)-31;
				local replacement=precodingtable[replacementIndex];
				result=string.sub(result,1,pos-1)..replacement..string.sub(result,pos+2);
			end
			pos=pos+1;
		until(pos>string.len(result));
	end

	return result;
end